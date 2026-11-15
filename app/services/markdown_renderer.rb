class MarkdownRenderer
  class TaskRenderer < Redcarpet::Render::HTML
    def list_item(text, _list_type)
      stripped = text.strip
      if stripped.start_with?("[ ] ")
        content = text.sub(/\A\s*\[ \]\s*/, "")
        %(<li class="task-list-item flex items-start gap-2 my-1"><input type="checkbox" class="task-checkbox mt-1 h-4 w-4 rounded border-neutral-700 bg-neutral-900 text-cyan-500 focus:ring-cyan-500/50 cursor-pointer accent-cyan-500"><span class="flex-1">#{content}</span></li>)
      elsif stripped.start_with?("[x] ", "[X] ")
        content = text.sub(/\A\s*\[[xX]\]\s*/, "")
        %(<li class="task-list-item flex items-start gap-2 my-1 line-through text-neutral-400"><input type="checkbox" class="task-checkbox mt-1 h-4 w-4 rounded border-neutral-700 bg-neutral-900 text-cyan-500 focus:ring-cyan-500/50 cursor-pointer accent-cyan-500" checked><span class="flex-1">#{content}</span></li>)
      else
        "<li>#{text}</li>"
      end
    end
  end

  class << self
    def render(text)
      return "" if text.blank?

      renderer = TaskRenderer.new(
        filter_html: false,
        hard_wrap: true,
        link_attributes: { target: "_blank", rel: "noopener noreferrer" }
      )

      markdown = Redcarpet::Markdown.new(
        renderer,
        autolink: true,
        fenced_code_blocks: true,
        tables: true,
        strikethrough: true,
        space_after_headers: true,
        superscript: true,
        underline: true,
        highlight: true,
        no_intra_emphasis: true
      )

      sanitizer = ActionView::Base.white_list_sanitizer rescue nil
      if sanitizer.nil?
        sanitizer = Rails::Html::SafeListSanitizer.new
      end

      sanitized = sanitizer.sanitize(
        markdown.render(text),
        tags: %w[
          h1 h2 h3 h4 h5 h6 p br hr ul ol li strong em b i s strike u del code pre
          blockquote table thead tbody tr th td a img mark input span
        ],
        attributes: %w[href src alt title target rel class id type checked disabled]
      )

      sanitized.html_safe
    end
  end
end
