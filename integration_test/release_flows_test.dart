// One native build, sequential isolated libraries, including real audio.
import 'writing_flow_test.dart' as writing;
import 'reading_flow_test.dart' as reading;
import 'speech_studio_test.dart' as speech;
import 'memory_flow_test.dart' as memory;
import 'debate_flow_test.dart' as debate;
import 'impromptu_flow_test.dart' as impromptu;
import 'data_flow_test.dart' as data;
import 'speech_hardware_test.dart' as hardware;

void main() {
  writing.main();
  reading.main();
  speech.main();
  memory.main();
  debate.main();
  impromptu.main();
  data.main();
  hardware.main();
}
