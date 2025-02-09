// CroneEngine_st_v
// noise into window comparator

Engine_st_v : CroneEngine {
   var <synth;

   *new { arg context, doneCallback;
      ^super.new(context, doneCallback);
   }

   alloc {
      SynthDef(\st_v, {
         var noise, amp;
         noise = WhiteNoise.ar;
         noise = LPF.ar(noise, \cutoff.kr);
         amp = {if(noise > \max.kr, amp = 0, if(noise < \min.kr, 0, 1))};
         noise = noise * amp * \level.kr;
         Out.ar(\out.ir, Pan2.ar(noise.tanh));	
      }).add;

      context.server.sync;

      synth = Synth.new(\st_v, [context.out_b], context.xg);

      // Commands

      this.addCommand("cutoff", "f", { arg msg;
         synth.set(\cutoff, msg[1]);
      });

      this.addCommand("min", "f", { arg msg;
         synth.set(\min, msg[1]);
      });

      this.addCommand("max", "f", { arg msg;
         synth.set(\max, msg[1]);
      });

      this.addCommand("level", "f", { arg msg;
         synth.set(\level, msg[1]);
      });
   }

   free {
      synth.free;
   }
}
