# frozen_string_literal: true

require 'spec_helper'

describe ActionMailer::Text::HtmlToPlainText do
  it 'converts a fragment' do
    expect(subject.convert_to_text('<p>Test</p>')).to match(/Test/)
  end

  it 'converts a body' do
    expect(subject.convert_to_text('
    <html>
    <title>Ignore me</title>
    <body>
    <p>Test</p>
    </body>
    </html>
    ')).to match(/Test/)
  end

  it 'ignores titles' do
    expect(subject.convert_to_text('
    <html>
    <title>Ignore me</title>
    <body>
    <p>Test</p>
    </body>
    </html>
    ')).not_to match(/Ignore me/)
  end

  it 'ignores header links' do
    expect(subject.convert_to_text('
    <html>
    <head>
    <link href="http://example.com/should/be/ignored.css" rel="stylesheet" />
    </head>
    <body>
    <p>Test</p>
    </body>
    </html>
    ')).not_to match(/\*/)
  end

  it 'ignores header titles' do
    expect(subject.convert_to_text('
    <html>
    <head>
    <title>Ignore me</title>
    </head>
    <body>
    <p>Test</p>
    </body>
    </html>
    ')).not_to match(/Ignore me/)
  end

  it 'converts a malformed body' do
    expect(subject.convert_to_text('
    <html>
    <title>Ignore me</title>
    <body>
    <p>Test
    ')).to match(/Test/)
  end

  it 'decodes html entities' do
    expect(subject.convert_to_text('
      c&eacute;dille gar&#231;on &amp; &agrave; &ntilde;
    ')).to eq('cédille garçon & à ñ')
  end

  it 'decodes html entities from a SafeBuffer' do
    expect(subject.convert_to_text(ActiveSupport::SafeBuffer.new('
      c&eacute;dille gar&#231;on &amp; &agrave; &ntilde;
    '))).to eq('cédille garçon & à ñ')
  end

  it 'strips whitespace' do
    expect(subject.convert_to_text("  \ttext\ntext\n")).to eq("text\ntext")
    expect(subject.convert_to_text("  \na \n a \t")).to eq("a\na")
    expect(subject.convert_to_text("  \na \n\t \n \n a \t")).to eq("a\n\na")
    expect(subject.convert_to_text('test text&nbsp;')).to eq('test text')
    expect(subject.convert_to_text('test        text')).to eq('test text')
  end

  it 'leaves spaces for spans' do
    expect(subject.convert_to_text('
    <html>
    <body>
    <p><span>Test</span>
    <span>line 2</span>
    </p>
    ')).to match(/Test line 2/)
  end

  it 'normalizes line breaks' do
    expect(subject.convert_to_text("Test text\r\nTest text")).to eq("Test text\nTest text")
    expect(subject.convert_to_text("Test text\nTest text")).to eq("Test text\nTest text")
  end

  it 'formats lists' do
    expect(subject.convert_to_text("<li class='123'>item 1</li> <li>item 2</li>\n")).to eq("* item 1\n* item 2")
    expect(subject.convert_to_text("<li>item 1</li> \t\n <li>item 2</li> <li> item 3</li>\n")).to eq("* item 1\n* item 2\n* item 3")
  end

  it 'strips html' do
    expect(subject.convert_to_text("<p class=\"123'45 , att\" att=tester>test <span class='te\"st'>text</span>\n")).to eq('test text')
  end

  it 'parses quoted angle brackets and unquoted link attributes' do
    expect(subject.convert_to_text('<a title="1 > 0" href=https://example.com>Link</a>'))
      .to eq('Link ( https://example.com )')
  end

  it 'keeps escaped markup as text instead of interpreting it as tags' do
    expect(subject.convert_to_text('<p>&lt;strong&gt;Text&lt;/strong&gt; &amp; more</p>'))
      .to eq('<strong>Text</strong> & more')
  end

  it 'preserves repeated content and image alt text' do
    expect(subject.convert_to_text('<p>Again</p><p>Again</p><img alt="A &amp; B">'))
      .to eq("Again\n\nAgain\n\nA & B")
  end

  it 'does not turn comments into visible content' do
    expect(subject.convert_to_text('<p>Before<!-- hidden > text --> after</p>')).to eq('Before after')
  end

  it 'normalizes fragments and recovers unclosed paragraphs' do
    expect(subject.convert_to_text('Before<p>Paragraph</p>After', nil))
      .to eq("Before\n\nParagraph\n\nAfter")
    expect(subject.convert_to_text('<p>First<p>Second', nil)).to eq("First\n\nSecond")
    expect(subject.convert_to_text('Before <strong>bold</strong> after', nil)).to eq('Before bold after')
  end

  it 'separates nested list items without losing surrounding text' do
    html = '<p>Before</p><ul><li>Outer<ul><li>Inner</li></ul>Tail</li><li>Next</li></ul><p>After</p>'

    expect(subject.convert_to_text(html, nil)).to eq("Before\n\n* Outer\n* Inner\nTail\n* Next\nAfter")
    expect(subject.convert_to_text('<ol><li>First<ol><li>Nested</li></ol></li><li>Last</li></ol>', nil))
      .to eq("* First\n* Nested\n* Last")
  end

  it 'omits scripts and styles in both documents and fragments' do
    hidden = '<script>var secret = "<p>hidden</p>";</script><style>.hidden { color: red; }</style>'

    expect(subject.convert_to_text("#{hidden}<p>Visible</p>", nil)).to eq('Visible')
    expect(subject.convert_to_text("<html><head>#{hidden}</head><body>Before#{hidden} after</body></html>", nil))
      .to eq('Before after')
  end

  it 'creates line breaks for p and br tags' do
    expect(subject.convert_to_text('<p>Test text</p><p>Test text</p>')).to eq("Test text\n\nTest text")
    expect(subject.convert_to_text("\n<p>Test text</p>\n\n\n\t<p>Test text</p>\n")).to eq("Test text\n\nTest text")
    expect(subject.convert_to_text("\n<p>Test text<br/>Test text</p>\n")).to eq("Test text\nTest text")
    expect(subject.convert_to_text("\n<p>Test text<br> \tTest text<br></p>\n")).to eq("Test text\nTest text")
    expect(subject.convert_to_text('Test text<br><BR />Test text')).to eq("Test text\n\nTest text")
  end

  it 'converts headings' do
    expect(subject.convert_to_text('<h1>Test</h1>')).to eq("****\nTest\n****")
    expect(subject.convert_to_text("\t<h1>\nTest</h1> ")).to eq("****\nTest\n****")
    expect(subject.convert_to_text("\t<h1>\nTest line 1<br>Test 2</h1> ")).to eq("***********\nTest line 1\nTest 2\n***********")
    expect(subject.convert_to_text('<h1>Test</h1> <h1>Test</h1>')).to eq("****\nTest\n****\n\n****\nTest\n****")
    expect(subject.convert_to_text('<h2>Test</h2>')).to eq("----\nTest\n----")
    expect(subject.convert_to_text("<h3> <span class='a'>Test </span></h3>")).to eq("Test\n----")
  end

  it 'wraps lines' do
    raw = ''
    100.times { raw += 'test ' }

    txt = subject.convert_to_text(raw, 20)

    lens = []
    txt.each_line { |l| lens << l.length }
    expect(lens.max).to be <= 20
  end

  it 'converts links' do
    # basic
    expect(subject.convert_to_text('<a href="http://example.com/">Link</a>')).to eq('Link ( http://example.com/ )')

    # nested html
    expect(subject
      .convert_to_text('<a href="http://example.com/"><span class="a">Link</span></a>'))
      .to eq('Link ( http://example.com/ )')

    # complex link
    expect(subject
      .convert_to_text('<a href="http://example.com:80/~user?aaa=bb&amp;c=d,e,f#foo">Link</a>'))
      .to eq('Link ( http://example.com:80/~user?aaa=bb&c=d,e,f#foo )')

    # attributes
    expect(subject
      .convert_to_text('<a title=\'title\' href="http://example.com/">Link</a>'))
      .to eq('Link ( http://example.com/ )')

    # spacing
    expect(subject
      .convert_to_text('<a href="   http://example.com/ "> Link </a>'))
      .to eq('Link ( http://example.com/ )')

    # multiple
    expect(subject
      .convert_to_text('<a href="http://example.com/a/">Link A</a> <a href="http://example.com/b/">Link B</a>'))
      .to eq('Link A ( http://example.com/a/ ) Link B ( http://example.com/b/ )')

    # merge links
    expect(subject.convert_to_text('<a href="%%LINK%%">Link</a>')).to eq('Link ( %%LINK%% )')
    expect(subject.convert_to_text('<a href="[LINK]">Link</a>')).to eq('Link ( [LINK] )')
    expect(subject.convert_to_text('<a href="{LINK}">Link</a>')).to eq('Link ( {LINK} )')

    # unsubscribe
    expect(subject.convert_to_text('<a href="[[!unsubscribe]]">Link</a>')).to eq('Link ( [[!unsubscribe]] )')
  end

  it 'ignores empty links' do
    expect(subject
      .convert_to_text('<a href="http://example.com/a/">Link A</a> <a href="http://example.com/b/"></a> <a href="http://example.com/c/">Link C</a>', nil))
      .to eq('Link A ( http://example.com/a/ ) Link C ( http://example.com/c/ )')
  end

  # see https://github.com/alexdunae/premailer/issues/72
  it 'converts multiple links per line' do
    expect(subject
      .convert_to_text('<p>This is <a href="http://www.google.com" >link1</a> and <a href="http://www.google.com" >link2 </a> is next.</p>', nil, 10_000))
      .to eq('This is link1 ( http://www.google.com ) and link2 ( http://www.google.com ) is next.')
  end

  # see https://github.com/alexdunae/premailer/issues/72
  it 'converts links within headings' do
    expect(subject
      .convert_to_text("<h1><a href='http://example.com/'>Test</a></h1>"))
      .to eq("****************************\nTest ( http://example.com/ )\n****************************")
  end
end
