require 'bluecloth'
require 'nokogiri'



class TartanCloth

  VERSION = "0.0.1"

  attr_accessor :title

  def initialize( markdown_file, title = nil )
    @markdown_file = markdown_file
    @title = title
  end

  def to_html_file( html_file )

    File.open( html_file, 'w') do |f|
      f << to_html()
    end
  end

  ###
  # Convert a markdown source file to HTML. If a header element with text TOC
  # exists within the markdown document, a Table of Contents will be generated
  # and inserted at that location.
  #
  # The TOC will only contain header (h1-h6) elements from the location of the
  # TOC header to the end of the document
  def to_html
    bc = BlueCloth::new( File::read( @markdown_file ), header_labels: true )
    content = bc.to_html

    content = build_toc( content )

    html = ""

    # Add a well formed HTML5 header.
    html << html_header(title)

    # Add the body content.
    html << content

    # Add the document closing tags.
    html << html_footer()
  end

  ###
  # Build a TOC based on headers located within HTML content.
  # If a header element with text TOC exists within the markdown document, a
  # Table of Contents will be generated and inserted at that location.
  #
  # The TOC will only contain header (h1-h6) elements from the location of the
  # TOC header to the end of the document
  def build_toc( html_content )
    # Generate Nokogiri elements from HTML
    doc = Nokogiri::HTML::DocumentFragment.parse( html_content )

    # Find the TOC header
    toc = find_toc_header(doc)

    # Just return what was passed to us if there's no TOC.
    return html_content if toc.nil?

    # Get all headers in the document, starting from the TOC header.
    headers = get_headers(doc, toc)

    # Build the link info for the TOC.
    toc_links = []
    headers.each do |element|
      toc_links << link_hash(element)
    end

    # Convert link info to markdown.
    toc_md = toc_to_markdown(toc_links)

    # Convert the TOC markdown to HTML
    bc = BlueCloth::new( toc_md, pseudoprotocols: true )
    toc_content = bc.to_html

    # Convert the TOC HTML to Nokogiri elements.
    toc_html = Nokogiri::HTML::DocumentFragment.parse(toc_content)

    # Add toc class to the <ul> element
    toc_html.css('ul').add_class('toc')

    # Insert the TOC content before the toc element
    toc.before(toc_html.children)

    # Remove the TOC header placeholder element.
    toc.remove

    # Return the HTML
    doc.to_html
  end

  ###
  # Convert an array of link hashes to markdown
  #
  # toc_links - hash of links
  # returns - markdown content
  def toc_to_markdown(toc_links)
    markdown = "## Table of Contents\n\n"
    toc_links.each do |link_data|
      text = link_data[:text]
      link = link_data[:link]
      klass = link_data[:klass]
      markdown << "+ [[#{text}](##{link})](class:#{klass})\n"
    end
    markdown << "\n"
  end

  ###
  # return the TOC header element or nil
  #
  # doc - Nokogiri DocumentFragment
  def find_toc_header(doc)
    return nil unless doc

    doc.children.each do |element|
      return element if is_toc_header(element)
    end

    return nil
  end

  ###
  # returns true if the element is a header (h1-h6) element
  def is_header_element(element)
    %w(h1 h2 h3 h4 h5 h6).include? element.name
  end

  ###
  # returns true when a header (h1-h6) element contains the text: TOC
  def is_toc_header(element)
    return (is_header_element(element) && element.text == 'TOC')
  end

  ###
  # Create an array of all header (h1-h6) elements in an HTML document
  # starting from a specific element
  #
  # starting_element - element to start parsing from
  # returns - array of Nokogiri elements
  def get_headers(doc, starting_element)
    headers = []
    capture = false

    doc.children.each do |element|
      unless capture
        capture = true if element == starting_element
        next
      end # unless

      headers << element if is_header_element(element)
    end

    headers
  end

  ###
  # Build a link hash for an element containing the text, link,
  # and a children array.
  #
  # element - Nokogiri element
  def link_hash(element)
    # The previous element should be a simple anchor.
    # Get the actual link value from the anchor.
    a = element.previous_element
    anchor_link = a.attributes['name'].value if a.name == 'a'

    # Store the header text (link text) and the anchor link and a class for styling.
    { text: element.text, link: anchor_link, klass: "#{element.name}toc" }
  end

  # Create an HTML5 header
  #
  # returns - HTML header and body open tags
  def html_header(title)
    styles = css()
    header = <<HTML_HEADER
<!DOCTYPE html>
<html>
  <head><title>#{title}</title></head>

  #{styles}

  <body>
    <div class="content">
      <div class="rendered-content">

HTML_HEADER
  end

  ###
  # Create some stylish CSS
  #
  # returns - html style element
  def css()
    styles = <<CSS
<style media="screen" type="text/css">
<!--
  body {
    font-family: Arial, sans-serif;
  }

  .content {
    margin: 0 auto;
    min-height: 100%;
    padding: 0 0 100px;
    width: 980px;
    border: 1px solid #ccc;
    border-radius: 5px;
  }

  .rendered-content {
    padding: 10px;
  }

  /* Fancy HR styles based on http://css-tricks.com/examples/hrs/ */
  hr {
    border: 0;
    height: 1px;
    background-image: -webkit-linear-gradient(left, rgba(200,200,200,1), rgba(200,200,200,0.5), rgba(200,200,200,0));
    background-image:    -moz-linear-gradient(left, rgba(200,200,200,1), rgba(200,200,200,0.5), rgba(200,200,200,0));
    background-image:     -ms-linear-gradient(left, rgba(200,200,200,1), rgba(200,200,200,0.5), rgba(200,200,200,0));
    background-image:      -o-linear-gradient(left, rgba(200,200,200,1), rgba(200,200,200,0.5), rgba(200,200,200,0));
  }

  h1 {
    font-size: 24px;
    font-weight: normal;
    line-height: 1.25;
  }

  h2 {
    font-size: 20px;
    font-weight: normal;
    line-height: 1.5;
  }

  h3 {
    font-size: 16px;
    font-weight: bold;
    line-height: 1.5625;
  }

  h4 {
    font-size: 14px;
    font-weight: bold;
    line-height: 1.5;
  }

  h5 {
    font-size: 12px;
    font-weight: bold;
    line-height: 1.66;
    text-transform: uppercase;
  }

  h6 {
    font-size: 12px;
    font-style: italic;
    font-weight: bold;
    line-height: 1.66;
    text-transform: uppercase;
  }

  pre  {
    margin-left: 2em;
    display: block;
    background: #f5f5f5;
    font-family: monospace;
    border: 1px solid #ccc;
    border-radius: 2px;
    padding: 1px 3px;
  }

  code {
    background: #f5f5f5;
    font-family: monospace;
    border: 1px solid #ccc;
    border-radius: 2px;
    padding: 1px 3px;
  }

  pre, code {
    font-size: 12px;
    line-height: 1.4;
  }

  pre code {
    border: 0;
    padding: 0;
  }

  ul.toc li {
    list-style: none;
    font-size: 14px;
  }

  ul.toc li span.h3toc {
    margin-left: 20px;
  }

  ul.toc li span.h4toc {
    margin-left: 40px;
  }

  ul.toc li span.h5toc {
    margin-left: 60px;
  }

  ul.toc li span.h6toc {
    margin-left: 80px;
  }
-->
</style>
CSS
  end

  ###
  # returns - HTML closing tags
  def html_footer()
    footer = <<HTML_FOOTER

      </div> <!-- .content -->
    </div> <!-- .rendered-content -->
  </body>
</html>
HTML_FOOTER
  end

end
