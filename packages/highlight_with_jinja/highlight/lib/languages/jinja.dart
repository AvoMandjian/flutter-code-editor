import '../src/common_modes.dart';
import '../src/mode.dart';

final jinja = Mode(
  refs: {
    '~contains~1~contains~0~starts~contains~0~contains~0': Mode(
      beginKeywords: "and as if in is not or",
      keywords: {"name": "and as if in is not or"},
      relevance: 0,
      contains: [Mode(className: "params", begin: "\\(", end: "\\)")],
    ),
    '~contains~1~contains~0~starts~contains~0': Mode(
      begin: "\\|[A-Za-z_]+:?",
      keywords:
          "abs attr batch capitalize default escape first float forceescape format groupby indent int join last length list lower map pprint random reject rejectattr replace reverse round safe select selectattr slice sort string striptags sum title trim truncate unique upper urlize wordcount wordwrap",
      contains: [Mode(ref: '~contains~1~contains~0~starts~contains~0~contains~0')],
    ),
  },
  case_insensitive: true,
  contains: [
    // Comments
    Mode(
      className: "comment",
      begin: "\\{#",
      end: "#\\}",
      contains: [
        PHRASAL_WORDS_MODE,
        Mode(className: "doctag", begin: "(?:TODO|FIXME|NOTE|BUG|XXX):", relevance: 0),
      ],
    ),

    // Tags
    Mode(
      className: "template-tag",
      begin: "\\{%-?",
      end: "-?%\\}",
      contains: [
        Mode(
          className: "name",
          begin: "\\w+",
          keywords: {
            "name":
                "block endblock call endcall macro endmacro set endset if elif else endif for endfor in is not and or recursive as import from with endwith include extends endblock",
            "template-tag": "true",
          },
          starts: Mode(
            endsWithParent: true,
            contains: [
              Mode(ref: '~contains~1~contains~0~starts~contains~0'),
              Mode(ref: '~contains~1~contains~0~starts~contains~0~contains~0'),
            ],
            relevance: 0,
          ),
        ),
      ],
    ),

    // Variables
    Mode(
      className: "template-variable",
      begin: "\\{\\{-?",
      end: "-?\\}\\}",
      contains: [
        Mode(self: true),
        Mode(ref: '~contains~1~contains~0~starts~contains~0'),
        Mode(ref: '~contains~1~contains~0~starts~contains~0~contains~0'),
      ],
    ),
  ],
);
