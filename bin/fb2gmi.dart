import 'dart:io';
import 'package:xml/xml.dart';
import 'package:fb2gmi/fb2gmi.dart';

class GmiBookHeader {
  final String title;
  final String authors;
  final String date;
  final String lang;

  const GmiBookHeader(this.title, this.authors, this.date, this.lang);

  @override
  String toString() =>
      'title: "$title", authors: "$authors", date: $date, lang: $lang';
}

typedef GmiBookParagraph = String;

class GmiBookChapter {
  final String header;
  final List<GmiBookParagraph> paragraphs;

  GmiBookChapter(this.header, this.paragraphs);
}

class GmiBook {
  final GmiBookHeader header;
  final List<GmiBookChapter> chapters;

  GmiBook(this.header, this.chapters);
}

GmiBookChapter? parseChapter(XmlNode section) {
  final title = section.getElement('header');
  if (title == null) return null;
  var header = '';
  title.findElements('p').forEach((p) => header = header + ". " + p.innerText);
  final paragraphs = List<GmiBookParagraph>.empty();
  section.findElements('p').forEach((p) => paragraphs.add(p.innerText));
  if (paragraphs.isEmpty) return null;
  return GmiBookChapter(header, paragraphs);
}

void main(List<String> arguments) async {
  print('fb2 to gmi converter');

  final fb2File = File(arguments[0]);
  final xmlContent = await fb2File.readAsString();
  final xml = XmlDocument.parse(xmlContent);
  final description = xml.rootElement.getElement('description')!;
  final titleInfo = description.getElement('title-info')!;
  final title = titleInfo.getElement('book-title')!.innerText;
  final authorInfo = titleInfo.getElement('author')!;
  final firstName = authorInfo.getElement('first-name')!.innerText;
  final lastName = authorInfo.getElement('last-name')!.innerText;
  final author = firstName + ' ' + lastName;
  final date = titleInfo!.getElement('date')!.innerText;
  final lang = titleInfo!.getElement('lang')!.innerText;
  final gmiHeader = GmiBookHeader(title, author, date, lang);
  final body = xml.rootElement.getElement('body')!;
  final gmiChapters = List<GmiBookChapter>.empty();
  body
      .findAllElements('section')
      .map((section) => parseChapter(section))
      .forEach((chapter) => {if (chapter != null) gmiChapters.add(chapter!)});
  //print(chapter);
  // if(chapter != null) gmiChapters.add(chapter);
  //});
  final gmiBook = GmiBook(gmiHeader, gmiChapters);
  print(gmiBook.header);
  print('chapters: ${gmiBook.chapters.length}');
}
