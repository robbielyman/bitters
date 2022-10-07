// Engine_Bitters
// Polyphony code is from MxSynths by infinitedigits @schollz

// Inherit methods from CroneEngine
Engine_Bitters : CroneEngine {
  var bitParameters;
  var bitVoices;
  var bitVoicesOn;
  var fnNoteOn, fnNoteOnMono, fnNoteOnPoly, fnNoteAdd;
  var fnNoteOff, fnNoteOffMono, fnNoteOffPoly;
  var pedalSustainOn=false;
  var pedalSostenutoOn=false;
  var pedalSustainNotes;
  var pedalSostenutoNotes;
  var bitPolyphonyMax=20;
  var bitPolyphonyCount=0;

  *new { arg context, doneCallback;
    ^super.new(context, doneCallback);
  }

  alloc {
    // initialize variables
    bitParameters=Dictionary.with(*["amp"->0.5,"monophonic"->0.0,
      "tri1"->1.0, "pulse1"->0.0, "tri2"->0.0, "pulse2"->1.0,
      "pitch1"->0.0, "pitch2"->0.0, "mpitch"->0.0, "lpitch"->0.0,
      "ratio1"->1.0, "ratio2"->1.0, "index1"->0.0, "index2"->0.0,
      "mindex1"->0.0, "mindex2"->0.0, "lindex1"->0.0, "lindex2"->0.0,
      "width1"->0.5, "width2"->0.5, 
      "mwidth1"->0.0, "mwidth2"->0.0, "lwidth1"->0.0, "lwidth2"->0.0,
      "sync"->0, "mix"->0.0, "degrade"->0.0,
      "lopass"->22000.0, "lores"->0.0,
      "mlopass"->1.0, "llopass"->0.0, "mlores"->0.0, "llores"->0.0,
      "hipass"->10.0, "hires"->0.0,
      "mhipass"->0.0, "lhipass"->0.0, "mhires"->0.0, "lhires"->0.0,
      "attack"->0.0015, "decay"->0.8, "sustain"->1.0, "release"->0.131,
      "mattack"->0.0015, "mdecay"->0.8, "msustain"->1.0, "mrelease"->0.131,
      "lfreq"->4.0, "lfade"->0.0]);
    bitVoices = Dictionary.new;
    bitVoicesOn = Dictionary.new;
    pedalSustainNotes = Dictionary.new;
    pedalSostenutoNotes = Dictionary.new;

    SynthDef("BittersSynth", {
      arg out, note=69, amp=0.5, gate=0,
      tri1=1, pulse1=0, tri2=0, pulse2=1, 
      pitch1=0.0, pitch2=0.0,
      ratio1=1, ratio2=1, index1=0.0, index2=0.0,
      mindex1=0.0, mindex2=0.0,
      lindex1=0.0, lindex2=0.0,
      width1=0.5, width2=0.5,
      mwidth1=0.0, mwidth2=0.0, lwidth1=0.0, lwidth2=0.0,
      sync=0.0, mix=0.0, degrade=0.0,
      mpitch=0.0, lpitch=0.0,
      lopass=22000, lores=0.0,
      mlopass=1.0, mlores=0.0, llopass=0.0, llores=0.0,
      hipass=10.0, hires=0.0,
      mhipass=0.0, mhires=0.0, lhipass=0.0, lhires=0.0,
      attack=0.0015, decay=0.8, sustain=1.0, release=0.131,
      mattack=0.0015, mdecay=0.8, msustain=1.0, mrelease=0.131,
      lfreq=4.0, lfade=0.0;

      var amp_env = Env.adsr(attack, decay, sustain, release, amp).kr(2,gate);
      var mod_env = Env.adsr(mattack, mdecay, msustain, mrelease).kr(0,gate);
      var lfo = LFTri.kr(lfreq, mul:Env.asr(lfade, 1, 10).kr(0,gate));
      var freq1 = (note + pitch1 + (1.2*mpitch*mod_env) + (1.2*lpitch*lfo)).midicps;
      var freq2 = (note + pitch2 + (1.2*mpitch*mod_env) + (1.2*lpitch*lfo)).midicps;
      var fm1 = SinOsc.ar(freq:(ratio1*freq1), 
        mul:(index1 + (2.0*mindex1*mod_env) + (2.0*lindex1*lfo)));
      var fm2 = SinOsc.ar(freq:(ratio2*freq2),
        mul:(index2 + (2.0*mindex2*mod_env) + (2.0*lindex2*lfo)));
      var pw1 = width1 + (0.5*mwidth1*mod_env) + (0.5*lwidth1*lfo);
      var pw2 = width2 + (0.5*mwidth2*mod_env) + (0.5*lwidth2*lfo);
      var osc1 = tri1*TrianglePTR.ar(freq:freq1, phase:fm1, width:pw1)
        + pulse1*PulsePTR.ar(freq:freq1, phase:fm1, width:pw1);
      var osc2 = tri2*TrianglePTR.ar(freq:freq2, phase:fm2, sync:(sync*osc1[1]), width:pw2)
        + pulse2*PulsePTR.ar(freq:freq2, phase:fm2, sync:(sync*osc1[1]), width:pw2);
      var snd = LinXFade2.ar(osc1[0], osc2[0], mix);
      var lofreq = lopass * (2.0.pow((5.0*mlopass*mod_env) + (2.5*llopass*lfo)));
      var hifreq = hipass * (2.0.pow((5.0*mhipass*mod_env) + (2.5*lhipass*lfo)));
      snd = Decimator.ar(snd, (48000.0 / (1.0 + (15.0*degrade))), (16.0-(12.0*degrade)));
      snd = SVF.ar(snd, hifreq, (hires + (mhires*mod_env) + (lhires*lfo)), lowpass:0, highpass:1);
      snd = SVF.ar(snd, lofreq, (lores + (mlores*mod_env) + (llores*lfo)));
      Out.ar(out, (snd*amp_env).dup);
    }).add;

    fnNoteOnMono = {
      arg note, amp, duration;
      var notesOn = false;
      var setNote = false;
      bitVoices.keysValuesDo({ arg key, syn;
        if (syn.isRunning, {
          notesOn = true;
        });
      });
      if (notesOn==false,{
        fnNoteOnPoly.(note,amp,duration);
      },{
        bitVoices.keysValuesDo({ arg key, syn;
          if (syn.isRunning,{
            syn.set(\gate,0,);
            if (setNote==false,{
              syn.set(\gate,1,
                \note,note
                );
              setNote = true;
            });
          });
        });
      });
      fnNoteAdd.(note);
    };

    fnNoteOnPoly = {
      arg note, amp, duration;

      bitVoices.put(note,
        Synth.new("BittersSynth",[
          \out, context.out_b,
          \note, note,
          \amp, amp*bitParameters.at("amp"),
          \gate, 1,
          \tri1, bitParameters.at("tri1"),
          \pulse1, bitParameters.at("pulse1"),
          \tri2, bitParameters.at("tri2"),
          \pulse2, bitParameters.at("pulse2"),
          \pitch1, bitParameters.at("pitch1"),
          \pitch2, bitParameters.at("pitch2"),
          \mpitch, bitParameters.at("mpitch"),
          \lpitch, bitParameters.at("lpitch"),
          \ratio1, bitParameters.at("ratio1"),
          \ratio2, bitParameters.at("ratio2"),
          \index1, bitParameters.at("index1"),
          \index2, bitParameters.at("index2"),
          \mindex1, bitParameters.at("mindex1"),
          \mindex2, bitParameters.at("mindex2"),
          \lindex1, bitParameters.at("lindex1"),
          \lindex2, bitParameters.at("lindex2"),
          \width1, bitParameters.at("width1"),
          \width2, bitParameters.at("width2"),
          \mwidth1, bitParameters.at("mwidth1"),
          \mwidth2, bitParameters.at("mwidth2"),
          \lwidth1, bitParameters.at("lwidth1"),
          \lwidth2, bitParameters.at("lwidth2"),
          \sync, bitParameters.at("sync"),
          \mix, bitParameters.at("mix"),
          \degrade, bitParameters.at("degrade"),
          \lopass, bitParameters.at("lopass"),
          \lores, bitParameters.at("lores"),
          \mlopass, bitParameters.at("mlopass"),
          \mlores, bitParameters.at("mlores"),
          \llopass, bitParameters.at("llopass"),
          \hipass, bitParameters.at("hipass"),
          \hires, bitParameters.at("hires"),
          \mhipass, bitParameters.at("mhipass"),
          \mhires, bitParameters.at("mhires"),
          \lhipass, bitParameters.at("lhipass"),
          \lhires, bitParameters.at("lhires"),
          \attack, bitParameters.at("attack"),
          \decay, bitParameters.at("decay"),
          \sustain, bitParameters.at("sustain"),
          \release, bitParameters.at("release"),
          \mattack, bitParameters.at("mattack"),
          \mdecay, bitParameters.at("mdecay"),
          \msustain, bitParameters.at("msustain"),
          \mrelease, bitParameters.at("mrelease"),
          \lfreq, bitParameters.at("lfreq"),
          \lfade, bitParameters.at("lfade"),
          ]);
      );
      NodeWatcher.register(bitVoices.at(note));
      fnNoteAdd.(note);
    };

    fnNoteAdd = {
      arg note;
      var oldestNote    = 0;
      var oldestNoteVal = 10000000;
      bitPolyphonyCount = bitPolyphonyCount + 1;
      bitVoicesOn.put(note, bitPolyphonyCount);
      if (bitVoicesOn.size > bitPolyphonyMax, {
        // remove the oldest note
        bitVoicesOn.keysValuesDo({ arg key, val;
          if (val < oldestNoteVal, {
            oldestNoteVal = val;
            oldestNote = key;
          });
        });
      ("max polyphony reached, removing note "++oldestNote).postln;
      fnNoteOff.(oldestNote);
      });
    };

    fnNoteOn = {
      arg note, amp, duration;
      if (bitParameters.at("monophonic") > 0, {
        fnNoteOnMono.(note, amp, duration);
      },{
        fnNoteOnPoly.(note, amp, duration);
      });
    };

    fnNoteOff = {
      arg note;
      if ((bitVoices.at(note)==nil) || ((bitVoices.at(note).isRunning==false) && (bitVoicesOn.at(note)==nil)),{},{
        if (bitParameters.at("monophonic") > 0, {
          fnNoteOffMono.(note);
        },{
          fnNoteOffPoly.(note);
        });
      });
    };

    fnNoteOffMono = {
      arg note;
      var notesOn = false;
      var playedAnother = false;
      bitVoicesOn.removeAt(note);
      bitVoicesOn.keysValuesDo({ arg note, syn;
        notesOn=true;
      });
      if (notesOn==false,{
        bitVoices.keysValuesDo({ arg note, syn;
          if (syn.isRunning, {
            syn.set(\gate, 0);
          });
        });
      },{
        // play another note that is pressed down
        bitVoices.keysValuesDo({ arg note, syn;
          if (syn.isRunning, {
            syn.set(\gate, 0);
            // play another note if we haven't yet
            if (playedAnother==false, {
              syn.set(\gate, 1, \note, note);
              playedAnother = true;
            });
          });
        });
      });
    };

    fnNoteOffPoly = {
      arg note;
      bitVoicesOn.removeAt(note);

      if (pedalSustainOn==true,{
        pedalSustainNotes.put(note,1);
      },{
        if ((pedalSostenutoOn==true) && (pedalSostenutoNotes.at(note) != nil),{},{
        bitVoices.at(note).set(\gate,0);
        });
      });
    };

    this.addCommand("bit_note_on", "iff", { arg msg;
      var note = msg[1];
      if (bitVoices.at(note)!=nil,{
        if (bitVoices.at(note).isRunning==true,{
          bitVoices.at(note).set(\gate, 0);
        });
      });
    fnNoteOn.(msg[1], msg[2], msg[3]);
    });

    this.addCommand("bit_note_off", "i", { arg msg;
      var note = msg[1];
      fnNoteOff.(note);
    });

    this.addCommand("bit_sustain", "i", { arg msg;
      pedalSustainOn=(msg[1]==1);
      if (pedalSustainOn==false, {
        pedalSustainNotes.keysValuesDo({ arg note, val;
          if (bitVoicesOn.at(note)==nil, {
            pedalSustainNotes.removeAt(note);
            fnNoteOff.(note);
          });
        });
      },{
        // add currently held down notes to pedal
        bitVoicesOn.keysValuesDo({ arg note, val;
          pedalSustainNotes.put(note,1);
        });
      });
    });

    this.addCommand("bit_sostenuto", "i", { arg msg;
      pedalSostenutoOn = (msg[1]==1);
      if (pedalSostenutoOn==false, {
        // release all notes that aren't held down
        pedalSostenutoNotes.keysValuesDo({ arg note, val;
          if (bitVoicesOn.at(note)==nil, {
            pedalSostenutoNotes.removeAt(note);
            fnNoteOff.(note);
          });
        });
      },{
        // otherwise add currently held notes
        bitVoicesOn.keysValuesDo({ arg note, val;
          pedalSostenutoNotes.put(note,1);
        });
      });
    });

    this.addCommand("bit_set_polyphony", "i", { arg msg;
      if (msg[1] == 1, {
        bitParameters.put("monophonic",1);
      },{
        bitParameters.put("monophonic",0);
        bitPolyphonyMax=msg[1];
      });
    });

    this.addCommand("bit_set", "sf", { arg msg;
      var key = msg[1].asString;
      var val = msg[2];
      bitParameters.put(key,val);
      switch (key,
        "amp", {},
        "attack", {},
        "decay", {},
        "sustain", {},
        "mattack", {},
        "mdecay", {},
        "msustain", {},
        {
          bitVoices.keysValuesDo({ arg note, syn;
            if (syn.isRunning==true,{
              syn.set(key.asSymbol,val);
            });
          });
        }
        );
    });
  }

  free {
    bitVoices.keysValuesDo({ arg key, value; value.free; });
  }
}
