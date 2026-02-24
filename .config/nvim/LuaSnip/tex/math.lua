--   t : text-only (not in math)
--   m : math-only (inline or display)
--   M : block math-only (display)
--   n : inline math-only
--   A : autosnippet
--   r : regex trigger
--   v : visual-only (selection)
--   w : word boundary (best-effort via wordTrig=true)
--   c : code block (best-effort)

local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local d = ls.dynamic_node
local f = ls.function_node

local unpack = table.unpack

-- -------------------------
-- Context helpers (math/text)
-- -------------------------
local function has_vimtex()
  return vim.fn.exists("*vimtex#syntax#in_mathzone") == 1
end

local function in_math()
  if has_vimtex() then
    return vim.fn["vimtex#syntax#in_mathzone"]() == 1
  end
  return false
end

local function in_display_math()
  if not in_math() then
    return false
  end

  -- Heuristic for $$...$$ fences
  local line = vim.api.nvim_get_current_line()
  local row, col0 = unpack(vim.api.nvim_win_get_cursor(0))
  local col = col0 + 1

  local before = line:sub(1, col)
  local after = line:sub(col + 1)

  local bb = select(2, before:gsub("%$%$", ""))
  local aa = select(2, after:gsub("%$%$", ""))

  if (bb % 2 == 1) and (aa % 2 == 1) then
    return true
  end

  -- Search above/below for $$ fence (best-effort)
  local start = vim.fn.search("\\$\\$", "bnW")
  local finish = vim.fn.search("\\$\\$", "nW")
  if start > 0 and finish > 0 and start ~= finish then
    local cur = vim.fn.line(".")
    return (start < cur and cur < finish)
  end

  return false
end

local function in_inline_math()
  return in_math() and not in_display_math()
end

local function in_text()
  return not in_math()
end

-- Best-effort "code block" detector (mostly for markdown; harmless in tex)
local function in_fenced_codeblock()
  local ft = vim.bo.filetype
  if ft ~= "markdown" and ft ~= "md" and ft ~= "vimwiki" and ft ~= "tex" and ft ~= "latex" then
    return false
  end
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local lines = vim.api.nvim_buf_get_lines(0, 0, row, false)
  local fence = 0
  for _, l in ipairs(lines) do
    if l:match("^```") then
      fence = fence + 1
    end
  end
  return (fence % 2 == 1)
end

-- Selected text (VISUAL)
local function get_visual(_, parent)
  local raw = parent and parent.snippet and parent.snippet.env and parent.snippet.env.SELECT_RAW
  if raw and raw ~= "" then
    return sn(nil, t(raw))
  end
  return sn(nil, i(1))
end

-- visual-only condition
local function has_visual_selection()
  -- LuaSnip sets SELECT_RAW when expanded from visual selection
  local ok = pcall(function()
    return ls.session.current_nodes and true or true
  end)
  if not ok then
    return false
  end
  return vim.fn.mode():match("[vV\22]") ~= nil
end

-- -------------------------
-- Tiny DSL: build snippet from "options" flags
-- -------------------------
local function make_snip(spec)
  local trig = spec.trig
  local dscr = spec.dscr or spec.name or trig

  local regTrig = spec.regTrig or false
  local wordTrig = spec.wordTrig
  if wordTrig == nil then
    wordTrig = (spec.opts and spec.opts:find("w", 1, true) ~= nil) or false
  end

  local snipType = (spec.opts and spec.opts:find("A", 1, true) ~= nil) and "autosnippet" or nil

  local condition = nil
  if spec.opts then
    if spec.opts:find("c", 1, true) then
      condition = in_fenced_codeblock
    elseif spec.opts:find("t", 1, true) then
      condition = in_text
    elseif spec.opts:find("M", 1, true) then
      condition = in_display_math
    elseif spec.opts:find("n", 1, true) then
      condition = in_inline_math
    elseif spec.opts:find("m", 1, true) then
      condition = in_math
    end
  end

  -- visual-only gate if 'v' flag used
  if spec.opts and spec.opts:find("v", 1, true) then
    local prev = condition
    condition = function()
      return (prev == nil or prev()) and has_visual_selection()
    end
  end

  local sopts = {
    trig = trig,
    name = dscr,
    dscr = dscr,
    regTrig = regTrig,
    wordTrig = wordTrig,
    snippetType = snipType,
    priority = spec.priority,
  }

  return s(sopts, spec.body, condition and { condition = condition } or nil)
end

local snippets = {}
local autosnippets = {}

local function push(spec)
  local snip = make_snip(spec)
  if spec.opts and spec.opts:find("A", 1, true) then
    table.insert(autosnippets, snip)
  else
    table.insert(snippets, snip)
  end
end

-- helper: repeat the text of insert node idx
local function rep(idx)
  return f(function(args)
    return args[1][1] or ""
  end, { idx })
end

-- -------------------------
-- “Variables” (for ${GREEK} etc.)
-- -------------------------
local GREEK = table.concat({
  "alpha",
  "beta",
  "gamma",
  "Gamma",
  "delta",
  "Delta",
  "epsilon",
  "varepsilon",
  "zeta",
  "theta",
  "Theta",
  "vartheta",
  "iota",
  "kappa",
  "lambda",
  "Lambda",
  "sigma",
  "Sigma",
  "upsilon",
  "Upsilon",
  "omega",
  "Omega",
}, "|")

local TRIG_FUNCS = table.concat({
  "arcsin",
  "sin",
  "arccos",
  "cos",
  "arctan",
  "tan",
  "csc",
  "sec",
  "cot",
}, "|")

local HYP_FUNCS = table.concat({
  "sinh",
  "cosh",
  "tanh",
  "coth",
}, "|")

-- -------------------------
-- Snippets (ported; no fmt/fmta anywhere)
-- -------------------------

-- Math mode helpers (text-only triggers)
push({
  trig = "mk",
  opts = "tA",
  dscr = "Inline math $...$",
  body = { t("$"), i(1), t("$"), i(0) },
})

push({
  trig = "dm",
  opts = "tAw",
  dscr = "Display math $$...$$",
  body = { t({ "$$", "" }), i(1), t({ "", "$$" }), i(0) },
})

push({
  trig = "beg",
  opts = "mA",
  dscr = "Begin/end environment (math)",
  body = {
    t("\\begin{"),
    i(1, "env"),
    t({ "}", "\t" }),
    i(2),
    t({ "", "\\end{" }),
    rep(1),
    t("}"),
    i(0),
  },
})

-- Text inside math
push({
  trig = "text",
  opts = "mA",
  dscr = "\\text{...}",
  body = { t("\\text{"), i(1), t("}"), i(0) },
})
push({
  trig = '"',
  opts = "mA",
  dscr = "\\text{...} (quote trigger)",
  body = { t("\\text{"), i(1), t("}"), i(0) },
})

-- Greek letters (math autos)
local greek_map = {
  ["@a"] = "\\alpha",
  ["@b"] = "\\beta",
  ["@g"] = "\\gamma",
  ["@G"] = "\\Gamma",
  ["@d"] = "\\delta",
  ["@D"] = "\\Delta",
  ["@e"] = "\\epsilon",
  [":e"] = "\\varepsilon",
  ["@z"] = "\\zeta",
  ["@t"] = "\\theta",
  ["@T"] = "\\Theta",
  [":t"] = "\\vartheta",
  ["@i"] = "\\iota",
  ["@k"] = "\\kappa",
  ["@l"] = "\\lambda",
  ["@L"] = "\\Lambda",
  ["@s"] = "\\sigma",
  ["@S"] = "\\Sigma",
  ["@u"] = "\\upsilon",
  ["@U"] = "\\Upsilon",
  ["@o"] = "\\omega",
  ["@O"] = "\\Omega",
  ["ome"] = "\\omega",
  ["Ome"] = "\\Omega",
}
for trig, repv in pairs(greek_map) do
  push({ trig = trig, opts = "mA", dscr = repv, body = { t(repv) } })
end

-- Basic operations
push({ trig = "sr", opts = "mA", body = { t("^{2}") } })
push({ trig = "cb", opts = "mA", body = { t("^{3}") } })
push({ trig = "rd", opts = "mA", body = { t("^{"), i(1), t("}"), i(0) } })
push({ trig = "_", opts = "mA", dscr = "subscript _{...}", body = { t("_{"), i(1), t("}"), i(0) } })
push({ trig = "sts", opts = "mA", dscr = "_\\text{...}", body = { t("_\\text{"), i(1), t("}"), i(0) } })
push({ trig = "sq", opts = "mA", body = { t("\\sqrt{ "), i(1), t(" }"), i(0) } })
push({ trig = "//", opts = "mA", body = { t("\\frac{"), i(1), t("}{"), i(2), t("}"), i(0) } })
push({ trig = "ee", opts = "mA", body = { t("e^{ "), i(1), t(" }"), i(0) } })
push({ trig = "invs", opts = "mA", body = { t("^{-1}") } })

push({
  trig = "([A-Za-z])(\\d)",
  opts = "rmA",
  regTrig = true,
  dscr = "Auto letter subscript: x2 -> x_{2}",
  priority = -1,
  body = f(function(_, snip)
    return snip.captures[1] .. "_{" .. snip.captures[2] .. "}"
  end),
})

push({
  trig = "([^\\\\])(exp|log|ln)",
  opts = "rmA",
  regTrig = true,
  dscr = "Auto add backslash: exp/log/ln",
  body = f(function(_, snip)
    return snip.captures[1] .. "\\" .. snip.captures[2]
  end),
})

push({ trig = "conj", opts = "mA", body = { t("^{*}") } })
push({ trig = "Re", opts = "mA", body = { t("\\mathrm{Re}") } })
push({ trig = "Im", opts = "mA", body = { t("\\mathrm{Im}") } })
push({ trig = "bf", opts = "mA", body = { t("\\mathbf{"), i(1), t("}"), i(0) } })
push({ trig = "rm", opts = "mA", body = { t("\\mathrm{"), i(1), t("}"), i(0) } })

-- Linear algebra
push({
  trig = "([^\\\\])(det)",
  opts = "rmA",
  regTrig = true,
  body = f(function(_, snip)
    return snip.captures[1] .. "\\det"
  end),
})
push({ trig = "trace", opts = "mA", body = { t("\\mathrm{Tr}") } })

-- Accents / vectors (regex)
local function oneletter_wrap(cmd)
  return f(function(_, snip)
    return ("\\" .. cmd .. "{" .. snip.captures[1] .. "}")
  end)
end
push({ trig = "([a-zA-Z])hat", opts = "rmA", regTrig = true, body = oneletter_wrap("hat") })
push({ trig = "([a-zA-Z])bar", opts = "rmA", regTrig = true, body = oneletter_wrap("bar") })
push({ trig = "([a-zA-Z])dot", opts = "rmA", regTrig = true, priority = -1, body = oneletter_wrap("dot") })
push({ trig = "([a-zA-Z])ddot", opts = "rmA", regTrig = true, priority = 1, body = oneletter_wrap("ddot") })
push({ trig = "([a-zA-Z])tilde", opts = "rmA", regTrig = true, body = oneletter_wrap("tilde") })
push({ trig = "([a-zA-Z])und", opts = "rmA", regTrig = true, body = oneletter_wrap("underline") })
push({ trig = "([a-zA-Z])vec", opts = "rmA", regTrig = true, body = oneletter_wrap("vec") })

-- Non-regex versions
push({ trig = "hat", opts = "mA", body = { t("\\hat{"), i(1), t("}"), i(0) } })
push({ trig = "bar", opts = "mA", body = { t("\\bar{"), i(1), t("}"), i(0) } })
push({ trig = "dot", opts = "mA", priority = -1, body = { t("\\dot{"), i(1), t("}"), i(0) } })
push({ trig = "ddot", opts = "mA", body = { t("\\ddot{"), i(1), t("}"), i(0) } })
push({ trig = "cdot", opts = "mA", body = { t("\\cdot") } })
push({ trig = "tilde", opts = "mA", body = { t("\\tilde{"), i(1), t("}"), i(0) } })
push({ trig = "und", opts = "mA", body = { t("\\underline{"), i(1), t("}"), i(0) } })
push({ trig = "vec", opts = "mA", body = { t("\\vec{"), i(1), t("}"), i(0) } })

-- More auto letter subscripts
push({
  trig = "([A-Za-z])_(\\d\\d)",
  opts = "rmA",
  regTrig = true,
  body = f(function(_, snip)
    return snip.captures[1] .. "_{" .. snip.captures[2] .. "}"
  end),
})

push({
  trig = "\\\\hat{([A-Za-z])}(\\d)",
  opts = "rmA",
  regTrig = true,
  body = f(function(_, snip)
    return "\\hat{" .. snip.captures[1] .. "}_{" .. snip.captures[2] .. "}"
  end),
})
push({
  trig = "\\\\vec{([A-Za-z])}(\\d)",
  opts = "rmA",
  regTrig = true,
  body = f(function(_, snip)
    return "\\vec{" .. snip.captures[1] .. "}_{" .. snip.captures[2] .. "}"
  end),
})
push({
  trig = "\\\\mathbf{([A-Za-z])}(\\d)",
  opts = "rmA",
  regTrig = true,
  body = f(function(_, snip)
    return "\\mathbf{" .. snip.captures[1] .. "}_{" .. snip.captures[2] .. "}"
  end),
})

-- Common subscripts
push({ trig = "xnn", opts = "mA", body = { t("x_{n}") } })
push({ trig = "\\xii", opts = "mA", priority = 1, body = { t("x_{i}") } })
push({ trig = "xjj", opts = "mA", body = { t("x_{j}") } })
push({ trig = "xp1", opts = "mA", body = { t("x_{n+1}") } })
push({ trig = "ynn", opts = "mA", body = { t("y_{n}") } })
push({ trig = "yii", opts = "mA", body = { t("y_{i}") } })
push({ trig = "yjj", opts = "mA", body = { t("y_{j}") } })

-- Symbols / relations
local simple_math = {
  ooo = "\\infty",
  sum = "\\sum",
  prod = "\\prod",
  ["+-"] = "\\pm",
  ["-+"] = "\\mp",
  ["..."] = "\\dots",
  nabl = "\\nabla",
  xx = "\\times",
  ["**"] = "\\cdot",
  para = "\\parallel",
  ["==="] = "\\equiv",
  ["!="] = "\\neq",
  [">="] = "\\geq",
  ["<="] = "\\leq",
  [">>"] = "\\gg",
  ["<<"] = "\\ll",
  simm = "\\sim",
  ["sim="] = "\\simeq",
  prop = "\\propto",
  ["<->"] = "\\leftrightarrow ",
  ["->"] = "\\to",
  ["!>"] = "\\mapsto",
  ["=>"] = "\\implies",
  ["=<"] = "\\impliedby",
  ["and"] = "\\cap",
  ["orr"] = "\\cup",
  ["inn"] = "\\in",
  notin = "\\not\\in",
  ["\\\\\\"] = "\\setminus",
  ["sub="] = "\\subseteq",
  ["sup="] = "\\supseteq",
  eset = "\\emptyset",
  LL = "\\mathcal{L}",
  HH = "\\mathcal{H}",
  CC = "\\mathbb{C}",
  RR = "\\mathbb{R}",
  ZZ = "\\mathbb{Z}",
  NN = "\\mathbb{N}",
}
for trig, repv in pairs(simple_math) do
  push({ trig = trig, opts = "mA", dscr = repv, body = { t(repv) } })
end

-- Structured versions of \sum and \prod (non-auto, options "m")
push({
  trig = "\\sum",
  opts = "m",
  dscr = "\\sum_{i=1}^N",
  body = {
    t("\\sum_{"),
    i(1, "i"),
    t("="),
    i(2, "1"),
    t("}^{"),
    i(3, "N"),
    t("} "),
    i(0),
  },
})
push({
  trig = "\\prod",
  opts = "m",
  dscr = "\\prod_{i=1}^N",
  body = {
    t("\\prod_{"),
    i(1, "i"),
    t("="),
    i(2, "1"),
    t("}^{"),
    i(3, "N"),
    t("} "),
    i(0),
  },
})

push({
  trig = "lim",
  opts = "mA",
  body = {
    t("\\lim_{ "),
    i(1, "n"),
    t(" \\to "),
    i(2, "\\infty"),
    t(" } "),
    i(0),
  },
})

push({
  trig = "set",
  opts = "mA",
  body = { t("\\{ "), i(1), t(" \\}"), i(0) },
})

-- Add backslash before Greek letters when typed bare
push({
  trig = "([^\\\\])(" .. GREEK .. ")",
  opts = "rmA",
  regTrig = true,
  dscr = "Add backslash before Greek letters",
  body = f(function(_, snip)
    return snip.captures[1] .. "\\" .. snip.captures[2]
  end),
})

-- Trig funcs backslash + spacing
push({
  trig = "([^\\\\])(" .. TRIG_FUNCS .. ")",
  opts = "rmA",
  regTrig = true,
  dscr = "Add backslash before trig funcs",
  body = f(function(_, snip)
    return snip.captures[1] .. "\\" .. snip.captures[2]
  end),
})

push({
  trig = "\\\\(" .. TRIG_FUNCS .. ")([A-Za-gi-z])",
  opts = "rmA",
  regTrig = true,
  dscr = "Space after trig funcs (skips h for sinh/cosh)",
  body = f(function(_, snip)
    return "\\" .. snip.captures[1] .. " " .. snip.captures[2]
  end),
})

push({
  trig = "\\\\(" .. HYP_FUNCS .. ")([A-Za-z])",
  opts = "rmA",
  regTrig = true,
  dscr = "Space after hyperbolic trig funcs",
  body = f(function(_, snip)
    return "\\" .. snip.captures[1] .. " " .. snip.captures[2]
  end),
})

-- Derivatives & integrals
push({
  trig = "par",
  opts = "m",
  body = {
    t("\\frac{ \\partial "),
    i(1, "y"),
    t(" }{ \\partial "),
    i(2, "x"),
    t(" } "),
    i(0),
  },
})

push({
  trig = "pa([A-Za-z])([A-Za-z])",
  opts = "rm",
  regTrig = true,
  body = f(function(_, snip)
    return "\\frac{ \\partial " .. snip.captures[1] .. " }{ \\partial " .. snip.captures[2] .. " } "
  end),
})

push({ trig = "ddt", opts = "mA", body = { t("\\frac{d}{dt} ") } })

push({
  trig = "([^\\\\])int",
  opts = "rmA",
  regTrig = true,
  priority = -1,
  body = f(function(_, snip)
    return snip.captures[1] .. "\\int"
  end),
})

push({
  trig = "\\int",
  opts = "m",
  body = { t("\\int "), i(1), t(" \\, d"), i(2, "x"), t(" "), i(0) },
})

push({
  trig = "dint",
  opts = "mA",
  body = {
    t("\\int_{"),
    i(1, "0"),
    t("}^{"),
    i(2, "1"),
    t("} "),
    i(3),
    t(" \\, d"),
    i(4, "x"),
    t(" "),
    i(0),
  },
})

push({ trig = "oint", opts = "mA", body = { t("\\oint") } })
push({ trig = "iint", opts = "mA", body = { t("\\iint") } })
push({ trig = "iiint", opts = "mA", body = { t("\\iiint") } })

push({
  trig = "oinf",
  opts = "mA",
  body = { t("\\int_{0}^{\\infty} "), i(1), t(" \\, d"), i(2, "x"), t(" "), i(0) },
})

push({
  trig = "infi",
  opts = "mA",
  body = { t("\\int_{-\\infty}^{\\infty} "), i(1), t(" \\, d"), i(2, "x"), t(" "), i(0) },
})

-- Visual operations (VISUAL)
push({
  trig = "U",
  opts = "mAv",
  dscr = "underbrace VISUAL",
  body = { t("\\underbrace{ "), d(1, get_visual), t(" }_{ "), i(2), t(" }"), i(0) },
})

push({
  trig = "O",
  opts = "mAv",
  dscr = "overbrace VISUAL",
  body = { t("\\overbrace{ "), d(1, get_visual), t(" }^{ "), i(2), t(" }"), i(0) },
})

push({
  trig = "B",
  opts = "mAv",
  dscr = "underset VISUAL",
  body = { t("\\underset{ "), i(1), t(" }{ "), d(2, get_visual), t(" }"), i(0) },
})

push({
  trig = "C",
  opts = "mAv",
  dscr = "cancel VISUAL",
  body = { t("\\cancel{ "), d(1, get_visual), t(" }"), i(0) },
})

push({
  trig = "K",
  opts = "mAv",
  dscr = "cancelto VISUAL",
  body = { t("\\cancelto{ "), i(1), t(" }{ "), d(2, get_visual), t(" }"), i(0) },
})

push({
  trig = "S",
  opts = "mAv",
  dscr = "sqrt VISUAL",
  body = { t("\\sqrt{ "), d(1, get_visual), t(" }"), i(0) },
})

-- Physics / QM / Chem
push({ trig = "kbt", opts = "mA", body = { t("k_{B}T") } })
push({ trig = "msun", opts = "mA", body = { t("M_{\\odot}") } })
push({ trig = "dag", opts = "mA", body = { t("^{\\dagger}") } })
push({ trig = "o+", opts = "mA", body = { t("\\oplus ") } })
push({ trig = "ox", opts = "mA", body = { t("\\otimes ") } })

push({ trig = "bra", opts = "mA", body = { t("\\bra{"), i(1), t("} "), i(0) } })
push({ trig = "ket", opts = "mA", body = { t("\\ket{"), i(1), t("} "), i(0) } })
push({
  trig = "brk",
  opts = "mA",
  body = { t("\\braket{ "), i(1), t(" | "), i(2), t(" } "), i(0) },
})
push({
  trig = "outer",
  opts = "mA",
  body = { t("\\ket{"), i(1, "\\psi"), t("} \\bra{"), rep(1), t("} "), i(0) },
})

push({ trig = "pu", opts = "mA", body = { t("\\pu{ "), i(1), t(" }"), i(0) } })
push({ trig = "cee", opts = "mA", body = { t("\\ce{ "), i(1), t(" }"), i(0) } })
push({ trig = "he4", opts = "mA", body = { t("{}^{4}_{2}He ") } })
push({ trig = "he3", opts = "mA", body = { t("{}^{3}_{2}He ") } })

-- FIXED: isotope snippet (no formatter)
push({
  trig = "iso",
  opts = "mA",
  body = {
    t("{}^{"),
    i(1, "4"),
    t("}_{"),
    i(2, "2"),
    t("}"),
    i(3, "He"),
    t(" "),
    i(0),
  },
})

-- Environments (matrices etc.) - block math only (M) like your original "MA"
local function env_snip(env)
  return {
    t("\\begin{"),
    t(env),
    t({ "}", "" }),
    i(1),
    t({ "", "\\end{" }),
    t(env),
    t("}"),
    i(0),
  }
end

push({ trig = "pmat", opts = "MA", body = env_snip("pmatrix") })
push({ trig = "bmat", opts = "MA", body = env_snip("bmatrix") })
push({ trig = "Bmat", opts = "MA", body = env_snip("Bmatrix") })
push({ trig = "vmat", opts = "MA", body = env_snip("vmatrix") })
push({ trig = "Vmat", opts = "MA", body = env_snip("Vmatrix") })
push({ trig = "matrix", opts = "MA", body = env_snip("matrix") })

push({ trig = "cases", opts = "mA", body = env_snip("cases") })
push({ trig = "align", opts = "mA", body = env_snip("align") })
push({ trig = "array", opts = "mA", body = env_snip("array") })

-- Brackets
push({ trig = "avg", opts = "mA", body = { t("\\langle "), i(1), t(" \\rangle "), i(0) } })
push({ trig = "norm", opts = "mA", priority = 1, body = { t("\\lvert "), i(1), t(" \\rvert "), i(0) } })
push({ trig = "Norm", opts = "mA", priority = 1, body = { t("\\lVert "), i(1), t(" \\rVert "), i(0) } })
push({ trig = "ceil", opts = "mA", body = { t("\\lceil "), i(1), t(" \\rceil "), i(0) } })
push({ trig = "floor", opts = "mA", body = { t("\\lfloor "), i(1), t(" \\rfloor "), i(0) } })
push({ trig = "mod", opts = "mA", body = { t("|"), i(1), t("|"), i(0) } })

push({ trig = "lr(", opts = "mA", body = { t("\\left( "), i(1), t(" \\right) "), i(0) } })
push({ trig = "lr{", opts = "mA", body = { t("\\left\\{ "), i(1), t(" \\right\\} "), i(0) } })
push({ trig = "lr[", opts = "mA", body = { t("\\left[ "), i(1), t(" \\right] "), i(0) } })
push({ trig = "lr|", opts = "mA", body = { t("\\left| "), i(1), t(" \\right| "), i(0) } })
push({ trig = "lra", opts = "mA", body = { t("\\left< "), i(1), t(" \\right> "), i(0) } })

-- Taylor expansion (ported; repeats via rep helper)
push({
  trig = "tayl",
  opts = "mA",
  dscr = "Taylor expansion",
  body = {
    i(1, "f"),
    t("("),
    i(2, "x"),
    t(" + "),
    i(3, "h"),
    t(") = "),
    rep(1),
    t("("),
    rep(2),
    t(") + "),
    rep(1),
    t("'("),
    rep(2),
    t(")"),
    rep(3),
    t(" + "),
    rep(1),
    t("''("),
    rep(2),
    t(") \\frac{"),
    rep(3),
    t("^{2}}{2!} + \\dots "),
    i(0),
  },
})

-- Identity matrix generator: idenN
push({
  trig = "iden(\\d)",
  opts = "rmA",
  regTrig = true,
  dscr = "N x N identity matrix",
  body = f(function(_, snip)
    local n = tonumber(snip.captures[1]) or 2
    local rows = {}
    for r = 1, n do
      local cols = {}
      for c = 1, n do
        cols[#cols + 1] = (r == c) and "1" or "0"
      end
      rows[#rows + 1] = table.concat(cols, " & ")
    end
    local body = table.concat(rows, " \\\\\n")
    return "\\begin{pmatrix}\n" .. body .. "\n\\end{pmatrix}"
  end),
})

return snippets, autosnippets
