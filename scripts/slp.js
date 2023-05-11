"use strict";

var numberWord0To9 = {
  0: "num/0:nul",
  1: "num/1:jedyn",
  2: "num/2:dwaj",
  3: "num/3:tři",
  4: "num/4:štyri",
  5: "num/5:pjeć",
  6: "num/6:šěsć",
  7: "num/7:sydom",
  8: "num/8:wosom",
  9: "num/9:dźewjeć",
};

var numberWord10To19 = {
  10: "num/10:dźesać",
  11: "num/11:jědnaće",
  12: "num/12:dwanaće",
  13: "num/13:třinaće",
  14: "num/14:štyrnaće",
  15: "num/15:pjatnaće",
  16: "num/16:šěsnaće",
  17: "num/17:sydomnaće",
  18: "num/18:wosomnaće",
  19: "num/19:dźewjatnaće",
};

var numberWord20To90 = {
  2: "num/20:dwaceći",
  3: "num/30:třiceći",
  4: "num/40:štyrceći",
  5: "num/50:pjećdźesat",
  6: "num/60:šěsćdźesat",
  7: "num/70:sydomdźesat",
  8: "num/80:wosomdźesat",
  9: "num/90:dźewjećdźesat",
};

var numberWord100To900 = {
  1: "num/100:sto",
  2: "num/200:dwěsćě",
  3: "num/300:třista",
  4: "num/400:štyrista",
  5: "num/500:pjećstow",
  6: "num/600:šěsćstow",
  7: "num/700:sydomstow",
  8: "num/800:wosomstow",
  9: "num/900:dźewjećstow",
};

var numberWord1000plus = {
  1e3: "num/1000:tysac",

  1e6: "[2]num/1mil:jedyn milion||num/1:jedyn+num/milion:milion", // milion maskulinum
  2e6: "[2]num/2mil:dwaj milionaj||num/2:dwaj+num/milionaj:milionaj",
  3e6: "[2]num/3mil:tři miliony||num/3:tři+num/miliony:miliony",
  4e6: "[2]num/4mil:štyri miliony||num/4:štyri+num/miliony:miliony",
  5e6: "[2]num/5mil:pjeć milionow||num/5:pjeć+num/milionow:milionow",
  "6e6+": "[2]num/milionow:milionow||num/milionow:milionow",

  1e9: "[2]num/1mrd:jedna miliarda||num/jedna+num/miliarda:miliarda", // miliarda femininum
  2e9: "[2]num/2mrd:dwě miliardźe||num/2mrd:dwě miliardźe",
  3e9: "[2]num/3mrd:tři miliardy||num/3:tři+num/miliardy:miliardy",
  4e9: "[2]num/4mrd:štyri miliardy||num/4:štyri+num/miliardy:miliardy",
  5e9: "[2]num/5mrd:pjeć miliardow||num/5:pjeć+num/miliardow:miliardow",
  "6e9+": "num/miliardow:miliardow",

  1e12: "[2]num/1bil:jedyn bilion||num/1:jedyn+num/bilion:bilion",  // bilion maskulinum
  2e12: "[2]num/2bil:dwaj bilionaj||num/2:dwaj+num/bilionaj:bilionaj",
  3e12: "[2]num/3bil:tři biliony||num/3:tři+num/biliony:biliony",
  4e12: "[2]num/4bil:štyri biliony||num/4:štyri+num/biliony:biliony",
  5e12: "[2]num/5bil:pjeć bilionow||num/5:pjeć+num/bilionow:bilionow",
  "6e12+": "num/bilionow:bilionow",
};

var hourFullWord1To12 = {
  1: "hour/full/1:jednej",
  2: "hour/full/2:dwěmaj",
  3: "hour/full/3:třoch",
  4: "hour/full/4:štyrjoch",
  5: "hour/full/5:pjećich",
  6: "hour/full/6:šesćich",
  7: "hour/full/7:sedmich",
  8: "hour/full/8:wosmich",
  9: "hour/full/9:dźewjećich",
  10: "hour/full/10:dźesaćich",
  11: "hour/full/11:jědnaćich",
  12: "hour/full/12:dwanaćich",
};

var hourWord1To4 = {
  1: "hour/1:jednu hodźinu",
  2: "hour/2:dwě hodźinje",
  3: "hour/3:tři hodźiny",
  4: "hour/4:štyri hodźiny",
};

const connectWordsMarker = "~";

function spellNumber0to99(num) {
  console.log("spellNumber0to99(): " + num);
  if (num < 0 || num > 100) {
    return ["misc/error"];
  }
  if (num < 10) {
    return [numberWord0To9[num]];
  } else if (num >= 10 && num < 20) {
    return [numberWord10To19[num]];
  } else if (num >= 20 && num < 100) {
    let num1 = Math.floor(num / 10);
    let num2 = num % 10;
    if (num2 == 0) {
      return [numberWord20To90[num1]];
    } else {
      let audioA = [];
      audioA.push(numberWord0To9[num2] + connectWordsMarker);
      audioA.push("misc/a:a" + connectWordsMarker);
      audioA.push(numberWord20To90[num1]);
      return audioA;
    }
  }
}

function spellNumber100to999(num) {
  console.log("spellNumber100to999(): " + num);
  if (num < 100 || num > 1000) {
    return ["misc/error"];
  }
  let audioA = [];
  //console.log(num);
  let num1 = Math.floor(num / 100);
  let num2 = num % 100;
  //console.log(num1);
  //console.log(num2);
  audioA.push(numberWord100To900[num1]);
  if (num2 > 0) audioA = audioA.concat(spellNumber0to99(num2));
  //console.log(audioA);
  return audioA;
}

function spellNumber0to999(num) {
  if (num >= 0 && num < 100) {
    return spellNumber0to99(num);
  } else if (num >= 100 && num < 1000) {
    return spellNumber100to999(num);
  }
  return ["misc/error"];
}

function spellNumber1000to999999(num) {
  let audioA = [];
  let num1 = Math.floor(num / 1e3);
  let num2 = num % 1e3;
  //console.log(num1);
  //console.log(num2);
  if (num1 > 0) {
    if (num1 != 1) {
      audioA = audioA.concat(spellNumber0to999(num1));
    }
    audioA.push(numberWord1000plus[1e3]);
  }
  if (num2 > 0) audioA = audioA.concat(spellNumber0to999(num2));
  return audioA;
}

function spellNumberMil(num) {
  let audioA = [];
  let num1 = Math.floor(num / 1e6);
  let num2 = num % 1e6;
  //console.log(num1);
  //console.log(num2);
  if (num1 > 0) {
    if (num1 == 1) {
      audioA.push(numberWord1000plus[1e6]);
    } else if (num1 == 2) {
      audioA.push(numberWord1000plus[2e6]);
    } else if (num1 == 3) {
      audioA.push(numberWord1000plus[3e6]);
    } else if (num1 == 4) {
      audioA.push(numberWord1000plus[4e6]);
    } else if (num1 == 5) {
      audioA.push(numberWord1000plus[5e6]);
    } else {
      audioA = audioA.concat(spellNumber0to999(num1));
      audioA.push(numberWord1000plus["6e6+"]);
    }
  }
  if (num2 > 0) audioA = audioA.concat(spellNumber1000to999999(num2));
  return audioA;
}

function spellNumberMrd(num) {
  let audioA = [];
  let num1 = Math.floor(num / 1e9);
  let num2 = num % 1e9;
  //console.log(num1);
  //console.log(num2);
  if (num1 == 1) {
    audioA.push(numberWord1000plus[1e9]);
  } else if (num1 == 2) {
    audioA.push(numberWord1000plus[2e9]);
  } else if (num1 == 3) {
    audioA.push(numberWord1000plus[3e9]);
  } else if (num1 == 4) {
    audioA.push(numberWord1000plus[4e9]);
  } else if (num1 == 5) {
    audioA.push(numberWord1000plus[5e9]);
  } else {
    audioA = audioA.concat(spellNumber0to999(num1));
    audioA.push(numberWord1000plus["6e9+"]);
  }
  if (num2 > 0) audioA = audioA.concat(spellNumberMil(num2));

  return audioA;
}

function spellNumberBil(num) {
  let audioA = [];
  let num1 = Math.floor(num / 1e12);
  let num2 = num % 1e12;
  //console.log(num1);
  //console.log(num2);
  if (num1 == 1) {
    audioA.push(numberWord1000plus[1e12]);
  } else if (num1 == 2) {
    audioA.push(numberWord1000plus[2e12]);
  } else if (num1 == 3) {
    audioA.push(numberWord1000plus[3e12]);
  } else if (num1 == 4) {
    audioA.push(numberWord1000plus[4e12]);
  } else if (num1 == 5) {
    audioA.push(numberWord1000plus[5e12]);
  } else {
    audioA = audioA.concat(spellNumber0to999(num1));
    audioA.push(numberWord1000plus["6e12+"]);
  }
  if (num2 > 0) audioA = audioA.concat(spellNumberMrd(num2));

  return audioA;
}

function spellNumber(num) {
  console.log(
    "spellNumber: number() = <" + num + ">" + " typeof " + typeof num
  );
  /*if (isNaN(num)) {
        return ["misc/error"];
    }
    else*/ if (num >= 0 && num < 1000) {
    return spellNumber0to999(num);
  } else if (num >= 1e3 && num < 1e6) {
    return spellNumber1000to999999(num);
  } else if (num >= 1e6 && num < 1e9) {
    return spellNumberMil(num);
  } else if (num >= 1e9 && num < 1e12) {
    return spellNumberMrd(num);
  } else if (num >= 1e12 && num < 1e15) {
    return spellNumberBil(num);
  }
  return ["misc/error"];
}

function spellNumberText(numText, hlos, spellEl) {
  //numText = "1000000000";
  console.log("spellNumberText: '" + numText + "'");
  let audio = null;
  if (numText === null || numText === "") {
    audio = ["misc/error"];
  } else {
    let num = parseInt(numText);
    audio = spellNumber(num);
  }
  playAudioA(audio, hlos, spellEl);
}

function spellNum() {
  let numText = document.getElementById("textfield").value;
  let numText1 = "";
  try {
    numText1 = eval(numText);
  } catch (err) {
    console.log(err);
  }
  let spellTextArea = document.getElementById("spelltextarea");
  let hlos = 1;
  let hlosEl = document.getElementById("hlos");
  if (hlosEl != null) hlos = hlosEl.value;
  //console.log("spellTextArea: "+spellTextArea);
  spellNumberText(numText1, hlos, spellTextArea);
}

function spellTime() {
  let hlos = 1;
  let hlosEl = document.getElementById("hlos");
  if (hlosEl != null) hlos = hlosEl.value;

  let spellTextArea = document.getElementById("spelltextarea");

  let full_hour = document.getElementById("full_hour").checked;
  let currentTime = true;
  let zeit = new Date();
  let hours = zeit.getHours();
  let min = zeit.getMinutes();
  let casText = document.getElementById("timefield").value;
  if (casText !== null && casText != "") {
    let casA = casText.split(":");
    hours = parseInt(casA[0]);
    min = parseInt(casA[1]);
    currentTime = false;
  }
  if (currentTime && full_hour) {
    min = 0;
  }
  if (isNaN(hours)) hours = 0;
  if (isNaN(min)) min = 0;
  console.log("hours: " + hours + " min: " + min + " full_hour: " + full_hour);
  let audioA = [];
  if (full_hour && min == 0 && hours >= 1 && hours <= 12) {
    console.log("full_hour!");
    audioA.push(hourFullWord1To12[hours]);
  } else {
    if (hours >= 1 && hours <= 4) {
      audioA.push(hourWord1To4[hours]);
    } else {
      audioA = audioA.concat(spellNumber(hours));
      audioA.push("misc/hodzin:hodźin");
    }
    if (min > 0) audioA = audioA.concat(spellNumber(min));
  }
  playAudioA(audioA, hlos, spellTextArea);
}

var audiopath = "audio/";

function getaudio(key, type, hlos) {
  let path = audiopath + hlos + "/" + type + "/" + key;
  if (hlos == 1) path += ".ogg";
  else path += ".mp3";
  console.log("getaudio:" + path);
  return new Audio(path);
}

function playAudioA(audio, hlos, spellEl) {
  let audioA = [];
  let audioTexts = [];
  console.log("playAudioA: processing... " + audio);

  for (let i = 0; i < audio.length; ++i) {
    console.log(i + ": " + audio[i]);
    let audio_hlosA = audio[i].split("||");
    // Bsp. [1,3]num/jedna+num/mrd1:miliarda||[2]num/1miliarda:jedna miliarda
    console.log("audio_hlosA: " + audio_hlosA);
    for (let j = 0; j < audio_hlosA.length; ++j) {
      let audio_hlosA_el = audio_hlosA[j];
      let hloskey = "";
      if (audio_hlosA_el.startsWith("[")) {
        hloskey = audio_hlosA_el.substring(1, audio_hlosA_el.indexOf("]"));
        audio_hlosA_el = audio_hlosA_el.substring(
          audio_hlosA_el.indexOf("]") + 1
        );
      }
      if (hloskey == "" || hloskey == hlos) {
        let audio_hlosA_elA = audio_hlosA_el.split("+");
        for (let k = 0; k < audio_hlosA_elA.length; ++k) {
          let typeKeyA = audio_hlosA_elA[k].split("/");
          let type = typeKeyA[0];
          // q&d
          console.log("typeKeyA.length:" + typeKeyA.length + " typeKeyA[1]: " + typeKeyA[1]);
          if (typeKeyA.length > 2)
            type += "/" + typeKeyA[1];
          let keyText = typeKeyA[typeKeyA.length - 1];
          let key = keyText;
          let text = keyText;
          let colonpos = keyText.indexOf(":");
          if (colonpos > 0) {
            key = keyText.substring(0, colonpos);
            text = keyText.substring(colonpos + 1);
          }
          console.log("type: " + type + " key: " + key);
          audioA.push(getaudio(key, type, hlos));
          audioTexts.push(text);
        }
        break;
      }
    }
  }
  spellEl.innerHTML = "";
  const addToOutput = function (text) {
    console.log("addToOutput: " + text);
    let curtext = spellEl.innerHTML;
    if (!curtext.endsWith(connectWordsMarker)) curtext += " ";
    else curtext = curtext.replaceAll(connectWordsMarker, "");
    curtext += text;
    spellEl.innerHTML = curtext;
  };
  let curaudio = null;
  for (let i = 0; i < audioA.length; ++i) {
    curaudio = audioA[i];
    curaudio.onended = function () {
      if (i < audioA.length - 1) {
        addToOutput(audioTexts[i + 1]);
        audioA[i + 1].play();
      }
    };
  }
  addToOutput(audioTexts[0]);
  audioA[0].play();
}
