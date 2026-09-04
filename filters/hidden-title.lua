-- Headings marked with the "hidden-title" class get a real table-of-contents/
-- navigation entry, but no visible heading text on the page itself — used
-- for chapters whose actual "title" is a graphic (e.g. a decorative image)
-- rather than the heading text.
--
-- For LaTeX/PDF: emit a chapter break with no printed title, a manual TOC
-- entry, and a hypertarget so internal links to this heading still resolve.
-- For HTML/EPUB: keep the real heading (so the reader's nav still lists it)
-- and let the template's CSS hide it visually on the page.

local function escape_latex(s)
  s = s:gsub("\\", "\\textbackslash{}")
  for _, pair in ipairs({
    { "&", "\\&" }, { "%%", "\\%%" }, { "%$", "\\%$" }, { "#", "\\#" },
    { "_", "\\_" }, { "{", "\\{" }, { "}", "\\}" }, { "~", "\\textasciitilde{}" },
    { "%^", "\\textasciicircum{}" },
  }) do
    s = s:gsub(pair[1], pair[2])
  end
  return s
end

function Header(el)
  if el.level ~= 1 or not el.classes:includes("hidden-title") then
    return el
  end

  if FORMAT:match("latex") then
    local title = escape_latex(pandoc.utils.stringify(el.content))
    -- \phantomsection immediately before \addcontentsline is the standard
    -- hyperref idiom for a manual TOC entry: it gives hyperref's linktoc
    -- machinery a target to point the entry's link at (otherwise the TOC
    -- entry has no anchor to attach a hyperlink to).
    local tex = "\\chapter*{}\n\\phantomsection\n\\addcontentsline{toc}{chapter}{" .. title .. "}\n"
    if el.identifier and el.identifier ~= "" then
      tex = tex .. "\\hypertarget{" .. el.identifier .. "}{}\n"
    end
    return pandoc.RawBlock("latex", tex)
  end

  return el
end
