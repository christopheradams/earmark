defmodule EarmarkHelpersTests.LinkParserTest do
  use ExUnit.Case

  alias Earmark.Helpers.LinkParser

  # describe "text part" do
    test "text part: empty" do
      assert {~s<[]()>, "", "", nil} == LinkParser.parse_link("[]()")
    end
    test "text part: incorrect" do
      assert nil == LinkParser.parse_link("([]")
      assert nil == LinkParser.parse_link("([]()")
    end
    test "text part: simple text" do
      assert {~s<[hello]()>, ~s<hello>, ~s<>, nil} == LinkParser.parse_link("[hello]()")
    end
    test "text part: text with escapes" do
      assert {~s<[hello[]()>, ~s<hello[>, ~s<>, nil} == LinkParser.parse_link("[hello\\[]()")
    end
    test "text part: text with many parts" do
      assert {~s<[hello( world])]()>, ~s<hello( world])>, ~s<>, nil} == LinkParser.parse_link("[hello( world\\])]()")
    end
    test "text part: simple imbrication" do
      assert {~s<[[hello]]()>, ~s<[hello]>, ~s<>, nil} == LinkParser.parse_link("[[hello]]()")
    end
    test "text part: complex imbrication" do
      assert {~s<[pre[iniside]suff]()>, ~s<pre[iniside]suff>, ~s<>, nil} == LinkParser.parse_link("[pre[iniside]suff]()")
    end
    test "text part: deep imbrication" do
      assert {~s<[pre[[in]]side])]()>, ~s<pre[[in]]side])>, ~s<>, nil} == LinkParser.parse_link("[pre[[in\\]]side])]()")
    end
    test "text part: missing closing brackets" do
      assert nil ==  LinkParser.parse_link("[pre[[in\\]side])]")
    end
  # end

  # describe "url part" do
    test "url part: incorrect" do
      assert nil == LinkParser.parse_link("[](")
      assert nil == LinkParser.parse_link("[text](url")
    end
    test "url part: simple url" do
      assert {~s<[text](url)>, ~s<text>, ~s<url>, nil} == LinkParser.parse_link("[text](url)")
    end
    test "url part: url with escapes" do
      assert {~s<[text](url))>, ~s<text>, ~s<url)>, nil} == LinkParser.parse_link("[text](url\\))")
    end
    test "url part: double )) at end" do
      assert {~s<[text](url)>, ~s<text>, ~s<url>, nil} == LinkParser.parse_link("[text](url))")
    end
    test "url part: url with many parts" do
      assert {~s<[text](pre[()>, ~s<text>, ~s<pre[(>, nil} == LinkParser.parse_link("[text](pre[\\()")
    end
    test "url part: simple imbrication" do
      assert {~s<[text]((url))>, ~s<text>, ~s<(url)>, nil} == LinkParser.parse_link("[text]((url))")
    end
    test "url part: complex imbrication" do
      assert {~s<[text](pre](in fix)suff)>, ~s<text>, ~s<pre](in fix)suff>, nil} == LinkParser.parse_link("[text](pre](in fix)suff)")
    end
    test "url part: deep imbrication" do
      assert {~s<[text](a(1)[((2) \\one)z)>, ~s<text>, ~s<a(1)[((2) \\one)z>, nil} == LinkParser.parse_link("[text](a(1)[((2) \\\\one)z)")
    end
    test "url part: missing closing parens" do
      assert nil ==  LinkParser.parse_link("[text](")
    end
  # end

  # describe "url part with title" do
    test "url part with title: simple url" do
      assert {~s<[text](url 'title')>, ~s<text>, ~s<url>, ~s<title>} == LinkParser.parse_link("[text](url 'title')")
      assert {~s<[text](url  "title")>, ~s<text>, ~s<url>, ~s<title>} == LinkParser.parse_link(~s<[text](url  "title")>)
    end

    test "url part with title: title escapes parens" do
      assert {~s<[text](url "(title")>, ~s<text>, ~s<url>, ~s<(title>} == LinkParser.parse_link(~s<[text](url "(title")>)
      assert {~s<[text](url "tit)le")>, ~s<text>, ~s<url>, ~s<tit)le>} == LinkParser.parse_link(~s<[text](url "tit)le")>)
    end
  # end

  # describe "deprecate in v1.1, remove in v1.2" do
    test "deprecated:  remove in v1.2" do
      assert {~s<[text](url "title')>, ~s<text>, ~s<url>, ~s<title>} == LinkParser.parse_link(~s<[text](url "title')>)
      assert {~s<[text](url 'title")>, ~s<text>, ~s<url>, ~s<title>} == LinkParser.parse_link(~s<[text](url 'title")>)
      src = ~s<[text](url 'title')title")title")>
      assert {src, ~s<text>, ~s<url>, ~s<title')title")title>} == LinkParser.parse_link(src)
    end
    test "deprecated:  title quotes cannot be escaped" do
      assert {~s<[text](url "title\\')>, ~s<text>, ~s<url>, ~s<title\\>} == LinkParser.parse_link(~s<[text](url "title\\')>)
      assert {~s<[text](url 'title\\")>, ~s<text>, ~s<url>, ~s<title\\>} == LinkParser.parse_link(~s<[text](url 'title\\")>)
    end
  # end

  # describe "url no title" do
    test "url no title: missing space" do
      assert {~s<[text](url'title')>, ~s<text>, ~s<url'title'>, nil} == LinkParser.parse_link("[text](url'title')")
      assert {~s<[text](url"title")>, ~s<text>, ~s<url"title">, nil} == LinkParser.parse_link(~s<[text](url"title")>)
    end
    test "url no title: no title even before v1.2" do
      assert {~s<[text](url"title')>, ~s<text>, ~s<url"title'>, nil} == LinkParser.parse_link(~s<[text](url"title')>)
      assert {~s<[text](url'title")>, ~s<text>, ~s<url'title"> , nil} == LinkParser.parse_link(~s<[text](url'title")>)
    end
    test "url no title: missing second quote" do
      assert {~s<[text](url "title)>, ~s<text>, ~s<url "title>, nil} == LinkParser.parse_link(~s<[text](url "title)>)
    end
  # end

end
