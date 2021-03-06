gem 'minitest'
require 'minitest/autorun'
require 'ruby2js/filter/esm'

describe Ruby2JS::Filter::ESM do
  
  def to_js(string, options={})
    _(Ruby2JS.convert(string, options.merge(
      eslevel: 2017,
      filters: [Ruby2JS::Filter::ESM],
      scope: self
    )).to_s)
  end
  
  describe "imports" do
    it "should handle a file import" do
      to_js('import "x.css"').
        must_include 'import "x.css"'
    end

    it "should handle a default import" do
      to_js('import X, "x.js"').
        must_include 'import X from "x.js"'
    end

    it "should handle a default import with from" do
      to_js('import X  from "x.js"').
        must_include 'import X from "x.js"'

      to_js('import X, from: "x.js"').
        must_include 'import X from "x.js"'
    end

    it "should handle a default import as start" do
      to_js('import X, as: "*", from: "x.js"').
        must_include 'import X as * from "x.js"'
    end

    it "should handle multiple named imports" do
      to_js('import [ X, Y, Z ], "xyz.js"').
        must_include 'import { X, Y, Z } from "xyz.js"'
    end

    it "should handle multiple named imports with from" do
      to_js('import [ X, Y, Z ], from: "xyz.js"').
        must_include 'import { X, Y, Z } from "xyz.js"'
    end
  end

  describe "exports" do
    it "should handle a default class" do
      to_js("export default class X < Y\nend").
        must_include "export default class X extends Y {"
    end

    it "should handle a default expression" do
      to_js("export default func = ->() { 123 } ").
        must_include "export default func = () => 123"

      to_js("export default hash = { a: 123 } ").
        must_include "export default hash = {a: 123}"
    end

    it "should handle named exports" do
      to_js("export class X < Y\nend").
        must_include "export class X extends Y {"

      to_js("export func = ->() { 123 } ").
        must_include "export const func = () => 123"
    end

    it "should handle final export statements" do
      to_js("export [ A, B ]").
        must_include "export { A, B }"

      to_js("export default A").
        must_include "export default A"

      to_js("export [ A, default: B ]").
        must_include "export { A, B as default }"
    end
  end

  describe "import as a function" do
    it "should leave import function calls alone" do
      to_js('X = await import("x.js")').
        must_equal 'const X = await import("x.js")'
    end
  end

  describe "autoimports option" do
    it "should autoimport for constants" do
      to_js('Foo.bar', autoimports: {Foo: 'foo.js'}).
        must_equal 'import Foo from "foo.js"; Foo.bar'
    end

    it "should autoimport for non-constants" do
      to_js('foo.bar', autoimports: {foo: 'foo.js'}).
        must_equal 'import foo from "foo.js"; foo.bar'
    end
  end

  describe Ruby2JS::Filter::DEFAULTS do
    it "should include ESM" do
      _(Ruby2JS::Filter::DEFAULTS).must_include Ruby2JS::Filter::ESM
    end
  end
end
