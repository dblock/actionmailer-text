# frozen_string_literal: true

require 'nokogiri'

module ActionMailer
  module Text
    # Converts HTML into plaintext with link destinations and basic structural formatting.
    module HtmlToPlainText
      def convert_to_text(html, line_length = 65, from_charset = 'UTF-8')
        HtmlToPlainText.convert_to_text(html, line_length, from_charset)
      end

      # Returns UTF-8 text, preserving the converter's paragraph, link, and heading formatting.
      def self.convert_to_text(html, line_length = 65, _from_charset = 'UTF-8')
        document = Nokogiri::HTML.parse(html.to_str, nil, 'UTF-8')
        txt = render_children(document.at_css('body') || document, line_length)
        txt = custom_word_wrap(txt, line_length) if line_length
        txt.gsub!(/\r\n?/, "\n")
        txt.tr!("\u00a0", ' ')
        txt.gsub!(/\n[ \t]+/, "\n")
        txt.gsub!(/[ \t]+\n/, "\n")
        txt.gsub!(/\n{3,}/, "\n\n")
        txt.gsub!(/ {2,}/, ' ')
        txt.strip
      end

      def self.render_children(node, line_length)
        node.children.each_with_object(''.dup) do |child, text|
          if child.element? && child.name == 'li'
            text.rstrip!
            text << "\n" unless text.empty?
          end
          text << render_node(child, line_length)
        end
      end

      def self.render_node(node, line_length)
        return render_text(node) if node.text?
        return '' unless node.element?
        return '' if %w[script style].include?(node.name)
        return node['alt'].to_s if node.name == 'img'
        return "\n" if node.name == 'br'

        text = render_children(node, line_length)
        case node.name
        when 'a'
          node['href'] && !text.strip.empty? ? "#{text.strip} ( #{node['href'].strip} )" : text
        when 'h1', 'h2', 'h3', 'h4', 'h5', 'h6'
          render_heading(text, node.name, line_length)
        when 'li'
          "* #{text.lstrip}\n"
        when 'ul', 'ol'
          "\n#{text.strip}\n"
        when 'p'
          "#{text}\n\n"
        else
          text
        end
      end

      def self.render_text(node)
        previous = node.previous_sibling
        following = node.next_sibling
        return ' ' if node.content.strip.empty? && !previous.nil? && !following.nil? &&
                      previous.name == 'span' && following.name == 'span'

        node.content
      end

      def self.render_heading(text, tag, line_length)
        text = text.strip
        length = text.lines.map { |line| line.strip.length }.max || 0
        length = [length, line_length].min if line_length
        rule = (tag == 'h1' ? '*' : '-') * length
        heading = %w[h1 h2].include?(tag) ? "#{rule}\n#{text}\n#{rule}" : "#{text}\n#{rule}"
        "\n\n#{heading}\n\n"
      end

      # Taken from Rails' word_wrap helper (http://api.rubyonrails.org/classes/ActionView/Helpers/TextHelper.html#method-i-word_wrap)
      def self.custom_word_wrap(txt, line_length)
        txt.split("\n").collect do |line|
          line.length > line_length ? line.gsub(/(.{1,#{line_length}})(\s+|$)/, "\\1\n").strip : line
        end * "\n"
      end
    end
  end
end
