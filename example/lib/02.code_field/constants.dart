const javaTemplateSource = '''
$templateSource
public class AgentCommunication {
    // Simulates agent-like communication between two 'agents'.
    // Mirrors Flutter A2A widget interop where one calls a method on another and gets a result.
    public static String agentCommunicate(String callerData, AgentProcessor receiver) {
        return receiver.process(callerData);
    }

    // Functional interface for Agent B's processing method
    @FunctionalInterface
    interface AgentProcessor {
        String process(String data);
    }

    public static void main(String[] args) {
        // Agent B's processor (lambda simulates Agent B)
        AgentProcessor receiverProcess = data -> data.toUpperCase() + " PROCESSED BY AGENT B";
        
        // Agent A calls Agent B
        String inputData = "hello from agent A";
        String output = agentCommunicate(inputData, receiverProcess);
        
        System.out.println("Agent A sent: " + inputData);
        System.out.println("Agent B returned: " + output);
    }
}
''';
const templateSource = '''
{% set dealershipName = dealership.name %}
{% set dealershipAddress = dealership.address %}
{% for i in [0,1,2,3]%}
  {{ dealershipName }} {{ i }}
{% endfor %}
''';

const templateSourceDebug = '''
<div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; color: #333; background-color: #f9f9f9; padding: 16px; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.05);">
  <div style="font-size: 18px; font-weight: 600; color: #111; margin-bottom: 16px; border-bottom: 1px solid #eee; padding-bottom: 8px;">
    Debug – Line {{lineNumber}}
  </div>

  <table style="border-collapse: collapse; width: 100%; border-radius: 8px; overflow: hidden;">
    <tr style="background-color: #f0f0f0;">
      <th style="border: 1px solid #e0e0e0; padding: 12px; text-align: left; font-weight: 600; color: #555; width: 150px;">Node Type:</th>
      <td style="border: 1px solid #e0e0e0; padding: 12px;"><span style="font-family: 'Courier New', Courier, monospace; background-color: #e7e7e7; padding: 2px 6px; border-radius: 4px; font-size: 14px;">{{nodeType}}</span></td>
    </tr>
    <tr style="background-color: #ffffff;">
      <th style="border: 1px solid #e0e0e0; padding: 12px; text-align: left; font-weight: 600; color: #555;">Node Name:</th>
      <td style="border: 1px solid #e0e0e0; padding: 12px;"><span style="font-family: 'Courier New', Courier, monospace; background-color: #e7e7e7; padding: 2px 6px; border-radius: 4px; font-size: 14px;">{{nodeName}}</span></td>
    </tr>
    <tr style="background-color: #f0f0f0;">
      <th style="border: 1px solid #e0e0e0; padding: 12px; text-align: left; font-weight: 600; color: #555;">Line Number:</th>
      <td style="border: 1px solid #e0e0e0; padding: 12px;"><span style="font-family: 'Courier New', Courier, monospace; background-color: #e7e7e7; padding: 2px 6px; border-radius: 4px; font-size: 14px;">{{lineNumber}}</span></td>
    </tr>
    <tr style="background-color: #ffffff;">
      <th style="border: 1px solid #e0e0e0; padding: 12px; text-align: left; font-weight: 600; color: #555;">Output So Far:</th>
      <td style="border: 1px solid #e0e0e0; padding: 12px; font-family: 'Courier New', Courier, monospace; font-size: 14px;">{{outputSoFar}}</td>
    </tr>
    <tr style="background-color: #f0f0f0;">
      <th style="border: 1px solid #e0e0e0; padding: 12px; text-align: left; font-weight: 600; color: #555;">Current Output:</th>
      <td style="border: 1px solid #e0e0e0; padding: 12px; font-family: 'Courier New', Courier, monospace; font-size: 14px;">{{currentOutput}}</td>
    </tr>
    <tr style="background-color: #ffffff;">
      <th style="border: 1px solid #e0e0e0; padding: 12px; text-align: left; font-weight: 600; color: #555;">Node Data:</th>
      <td style="border: 1px solid #e0e0e0; padding: 12px; font-family: 'Courier New', Courier, monospace; font-size: 14px;">{{nodeData}}</td>
    </tr>
    <tr style="background-color: #f0f0f0;">
      <th style="border: 1px solid #e0e0e0; padding: 12px; text-align: left; font-weight: 600; color: #555;">Local variables:</th>
      <td style="border: 1px solid #e0e0e0; padding: 0;">
        <table style="border-collapse: collapse; width: 100%;">
          {% for key, value in variables %}
            <tr style="background-color: #fafafa;">
              <th colspan="2" style="border: 1px solid #e0e0e0; padding: 10px; text-align: left; font-weight: 600; color: #333; background-color: #e9e9e9;">{{key}}</th>
            </tr>
            <tr style="background-color: #ffffff;">
              <td colspan="2" style="border: 1px solid #e0e0e0; padding: 10px;">
                <json-editor>{{value | tojson}}</json-editor>
              </td>
            </tr>
          {% endfor %}
        </table>
      </td>
    </tr>
  </table>
</div>
''';

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
