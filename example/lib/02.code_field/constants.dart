const templateSource = '''
{% set dealershipName = dealership.name %}
{% set dealershipAddress = dealership.address %}
{% for i in [0,1,2,3]%}
  {{ dealershipName }} {{ i }}
{% endfor %}
''';

const templateSourceDebug = '''
<div style="
  font-family: 'SF Mono', 'Roboto Mono', monospace;
  background: #1e1e1e;
  color: #dcdcdc;
  padding: 20px;
  border-radius: 12px;
  box-shadow: 0 6px 12px rgba(0,0,0,0.3);
  overflow-x: auto;
  border: 1px solid #2d2d2d;
  margin: auto;
">
  <style>
    .debug-title {
      font-size: 16px;
      font-weight: 600;
      color: #9cdcfe;
      margin-bottom: 16px;
      padding-bottom: 8px;
      border-bottom: 1px solid #333;
    }
    .debug-panel {
      border-collapse: collapse;
      font-size: 14px;
    }
    .debug-panel th, .debug-panel td {
      text-align: left;
      padding: 10px 14px;
      border-bottom: 1px solid #333;
      vertical-align: top;
      word-break: break-word;
    }
    .debug-panel th {
      color: #9cdcfe;
      font-weight: 600;
      background: #252526;
      border-right: 1px solid #333;
    }
    .debug-panel tr:hover {
      background: #2a2d2e;
    }
    .debug-panel tr:last-child td {
      border-bottom: none;
    }
    .debug-panel pre {
      margin: 0;
      padding: 8px 10px;
      background: #252526;
      border-radius: 6px;
      white-space: pre-wrap;
      font-family: inherit;
      font-size: 13px;
      line-height: 1.4;
      overflow-x: auto;
    }
    .debug-panel .json-value {
      color: #ce9178;
    }
    .debug-panel .json-key {
      color: #9cdcfe;
    }
  </style>

  <!-- Title -->
  <div class="debug-title">
    Debug – Line {{lineNumber}}
  </div>

  <table class="debug-panel">
    <tr>
      <th>Node Type:</th>
      <td><span class="json-value">{{nodeType}}</span></td>
    </tr>
    <tr>
      <th>Node Name:</th>
      <td><span class="json-value">{{nodeName}}</span></td>
    </tr>
    <tr>
      <th>Line Number:</th>
      <td><span class="json-value">{{lineNumber}}</span></td>
    </tr>
    <tr>
      <th>Output So Far:</th>
      <td>{{outputSoFar}}</td>
    </tr>
    <tr>
      <th>Node Data:</th>
      <td>{{nodeData}}</td>
    </tr>
    <tr>
      <td>
      <br>
        <table>
          <tr>
            <th>Local variables:</th>
          </tr>
          {% for key, value in variables %}
            <tr>
              <th>{{key}} ----> </th>
              <td>{{value}}</td>
            </tr>
          {% endfor %}
        </table>
      </td>
    </tr>
  </table>
</div>''';

final Map<String, dynamic> dataToPassToJinja = {
  'subcategory_title': 'Su',
  'subcategory_title_2': 'Su 2',
  'subcategory_title_3': 'Su 3',
  'subcategory_title_4': 'Su 4',
  'dealership': {'name': 'Dealership', 'address': '123 Main St'},
};

final Map<String, dynamic> customThemes = {
  'custom_theme': {
    'root': {
      'backgroundColor': '0xffffffff',
      'color': '0xff000000',
    },
    'comment': {
      'color': '0xff008000',
    },
    'quote': {
      'color': '0xff008000',
    },
    'variable': {
      'color': '0xff008000',
    },
    'keyword': {
      'color': '0xff0000ff',
    },
    'selector-tag': {
      'color': '0xff0000ff',
    },
    'built_in': {
      'color': '0xff0000ff',
    },
    'name': {
      'color': '0xff0000ff',
    },
    'tag': {
      'color': '0xff0000ff',
    },
    'string': {
      'color': '0xffa31515',
    },
    'title': {
      'color': '0xffa31515',
    },
    'section': {
      'color': '0xffa31515',
    },
    'attribute': {
      'color': '0xffa31515',
    },
    'literal': {
      'color': '0xffa31515',
    },
    'template-tag': {
      'color': '0xffa31515',
    },
    'template-variable': {
      'color': '0xffa31515',
    },
    'type': {
      'color': '0xffa31515',
    },
    'addition': {
      'color': '0xffa31515',
    },
    'deletion': {
      'color': '0xff2b91af',
    },
    'selector-attr': {
      'color': '0xff2b91af',
    },
    'selector-pseudo': {
      'color': '0xff2b91af',
    },
    'meta': {
      'color': '0xff2b91af',
    },
    'doctag': {
      'color': '0xff808080',
    },
    'attr': {
      'color': '0xffff0000',
    },
    'symbol': {
      'color': '0xff00b0e8',
    },
    'bullet': {
      'color': '0xff00b0e8',
    },
    'link': {
      'color': '0xff00b0e8',
    },
    'emphasis': {
      'font_style': 'italic',
    },
    'strong': {
      'font_weight': 'bold',
    },
    // Added missing keys from standard themes
    'subst': {
      'color': '0xff000000',
    },
    'selector-id': {
      'color': '0xffa31515',
    },
    'selector-class': {
      'color': '0xffa31515',
    },
    'regexp': {
      'color': '0xff2b91af',
    },
    'meta-string': {
      'color': '0xff2b91af',
    },
    'meta-keyword': {
      'color': '0xff0000ff',
      'font_weight': 'bold',
    },
    'builtin-name': {
      'color': '0xff0000ff',
    },
    'params': {
      'color': '0xffa31515',
    },
    'formula': {
      'color': '0xff808080',
    },
    'code': {
      'color': '0xff008000',
    },
    'number': {
      'color': '0xffa31515',
    },
  },
};
