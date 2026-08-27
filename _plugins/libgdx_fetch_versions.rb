# This plugin automatically fetches the name of the latest version of libGDX

require "jekyll"
require 'json'
require 'open-uri'

module LibGDXFetchVersions
  class VersionDataGenerator < Jekyll::Generator
    safe true
    priority :highest

    def generate(site)
        site.data['versions'] = Hash.new
        site.data['versions']['libgdxRelease'] = site.data.dig('versions', 'libgdxRelease') || '1.13.1'
    end

  end
end
