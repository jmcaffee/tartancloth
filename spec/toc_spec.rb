require 'spec_helper'

describe "TOC" do

  context "headers" do

    it "identical headers have unique anchors" do
      the_indented_markdown( <<-"---" ).should be_transformed_into(<<-"---").without_indentation
      # TOC

      # Header 1

      # Header 1

      # Header 1
      ---
      <a name="TOC"></a>
      <h2>Table of Contents</h2>

      <ul class="toc">
      <li><span class="h1toc"><a href="#Header.1">Header 1</a></span></li>
      <li><span class="h1toc"><a href="#Header.1.0">Header 1</a></span></li>
      <li><span class="h1toc"><a href="#Header.1.1">Header 1</a></span></li>
      </ul>

      <a name="Header.1"></a>
      <h1>Header 1</h1>

      <a name="Header.1.0"></a>
      <h1>Header 1</h1>

      <a name="Header.1.1"></a>
      <h1>Header 1</h1>
      ---
    end
  end # context "headers"
end # describe "TOC"
