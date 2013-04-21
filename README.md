# TartanCloth

A wrapper around the BlueCloth gem which incorporates HTML5 headers, footers,
and a table of contents all with a nice stylesheet.

## Installation

Add this line to your application's Gemfile:

    gem 'tartancloth'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tartancloth

## Usage

TartanCloth's main feature is that it generates a _linked_ Table of Contents
from the headers (`h1, h2, h3, h4, h5, h6`) in your markdown document.

Simply add a header at any header level (level 2: `h2`, shown here):

    ## TOC

TartanCloth will parse the document and collect all headers **after** the TOC
and create a Table of Contents. The Table of Contents will be inserted at the
location of the `## TOC` header, replacing it.

In most of my documents, I include the Title (h1) and a summary before
displaying the TOC. I didn't want to include the sections prior to the TOC in
the Table of Contents, that's why header collection starts after.

### Quick Example

A quick example of using TartanCloth.

Given the following markdown:

###### markdown.md

    # My Wrench User Manual

    ## Summary

    My Wrench is an awesome tool blah, blah blah.

    - - -
    ## TOC

    - - -
    ## Running Wrench from the command line

    How to run wrench from the command line

    - - -
    ## Documentation Conventions

    Text surrounded with square brackets [] is optional.
    Text formatted like `this` indicates a _keyword_.

    ### Some Other Header

    #### Another, Deeper Header

    ##### Yet Another Header

    - - -
    ## Look at this header

    ###### Small Note Header


Markit.rb will convert the markdown to HTML, with an embedded stylesheet and
include a Table of Contents.

###### markit.rb

    require 'tartancloth'

    title = 'My Markdown'
    mdsrc = 'path/to/my/markdown.md'
    mdout = 'path/to/my/markdown.html'

    puts "Title:  #{title}"
    puts "Source: #{mdsrc}"
    puts "Output: #{mdout}"

    TartanCloth.new( mdsrc, title ).to_html_file( mdout )

- - -
### Using TartanCloth from a Rake Task

I like to use TartanCloth from a rake task to generate pretty docs.

###### markdown.rake

    require "pathname"
    require 'tartancloth'

    # Call this as: rake md2html[path/to/file/to/convert.md]
    #
    desc "Convert a .MD file to HTML"
    task :md2html, [:mdfile] do |t, args|
      Rake::Task['markdown:md2html'].invoke( args[:mdfile] )
    end


    namespace :markdown do

      desc "md2html usage instructions"
      task :help do
        puts <<HELP

    ----------------------------------------------------------------------

    Usage: md2html

    Generate HTML from a markdown document

      The generated HTML document will be located in the same location as
      the source markdown document.

      To generate the document, call it as follows:

        rake md2html[path/to/doc.md]

      Note that no quotes are needed.

      To set the title of the document, provide it as an ENV variable:

        TITLE="My Title" rake md2html[path/to/doc.md]

      If no title is given, the title will default to the filename.

    ----------------------------------------------------------------------

    HELP
      end


      task :md2html, [:mdfile] do |t, args|
        args.with_defaults(:mdfile => nil)
        if args[:mdfile].nil?
          puts "ERROR: Full path to file to convert required."
          puts
          puts "usage:  rake md2html['path/to/md/file.md']"
          exit
        end

        mdsrc = args[:mdfile]
        mdout = mdsrc.pathmap( "%X.html" )
        title = ENV['TITLE']

        puts "Title:  #{title}"
        puts "Source: #{mdsrc}"
        puts "Output: #{mdout}"

        TartanCloth.new( mdsrc, title ).to_html_file( mdout )
      end

    end # namespace :markdown

- - -
### A Task to Generate a User Manual

I use the tasks above to generate a user manual as well:

###### Rakefile

    require "bundler/gem_tasks"

    desc 'Generate user manual HTML'
    task :man do

      ENV['TITLE'] = 'User Manual'

      Rake::Task['markdown:md2html'].invoke( 'docs/user_manual.md' )
      Rake::Task['markdown:md2html'].reenable

    end

- - -
## Credits

+   [BlueCloth](https://github.com/ged/bluecloth) is used to generate the markdown
+   [Nokogiri](http://nokogiri.org/) is used to generate the table of contents
+   Chris Coyier has some [great code for pretty HRs](http://css-tricks.com/examples/hrs/)

- - -
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
