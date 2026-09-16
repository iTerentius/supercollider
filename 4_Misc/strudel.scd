(
  s.options.numWireBufs = 128;
  s.reboot;
  )


  (
  ~dirt = SuperDirt(2, s);
  fork {
      ~dirt.loadSoundFiles;
      ~strudelSamplesPath = "/home/hypo/.local/share/strudel-samples";
      if(File.exists(~strudelSamplesPath), {
          ~dirt.loadSoundFiles(~strudelSamplesPath +/+ "*");
      });
      s.sync;
      ~dirt.start(57120, [0]);
      "SuperDirt ready.".postln;
  };
  )
  OSCFunc.trace(false);

  ~dirt.loadSoundFiles("/home/hypo/.local/share/strudel-samples/*");


~dirt.doNotReadYet = true;  // index only; real audio loads lazily on first play

~dirt.loadSoundFiles("~/Music/supercollider/_samples/808s_by_SHD/808_kit/Bass_Drums/");  // -> 808_kit, Classic, Layered, ...
~dirt.loadSoundFiles("~/Music/supercollider/_samples/808s_by_SHD/808_kit/Hats/");  // -> 808_kit, Classic, Layered, ...
~dirt.loadSoundFiles("~/Music/supercollider/_samples/808s_by_SHD/808_kit/*");  // -> 808_kit, Classic, Layered, ...
~dirt.loadSoundFiles("~/Music/supercollider/_samples/Hoarder/");      // -> hoarder
~dirt.loadSoundFiles("~/Music/supercollider/_samples/");              // -> Neutron_12, Field, Cat-Water (flat kits)
~dirt.loadSoundFiles("~/Music/supercollider/_samples/Field/");        // -> Bambu, Storm (Field's subfolders)
~dirt.loadSoundFiles("~/Music/supercollider/_samples/AKWF/*");         // -> AKWF_0001 ... AKWF_0065
(
~strudelDirtAutoLoad = { |sound|
      if(~strudelDirtLoadFailed.includes(sound).not) {
          ~strudelDirtLoadFailed.add(sound);
          ~dirt.loadOnly([sound], ~strudelSamplesPath);
          if(~dirt.buffers.at(sound).notNil) { ~strudelDirtLoadFailed.remove(sound) };
      } {
          "[strudel] couldn't load soundfile for %\n".format(sound).postln;
      };
  };
  ~dirt.set(\notFound, { ~strudelDirtAutoLoad.(~s) });
)
