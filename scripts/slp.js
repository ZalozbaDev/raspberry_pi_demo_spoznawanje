var audiopath = "audio/";

function getaudio(key, type, hlos) {
	const execSync = require('child_process').execSync;

    let path = audiopath + hlos + "/" + type + "/" + key;
    if (hlos == 1)
        path += ".ogg";
    else
        path += ".mp3";
    console.log(path);

    const output1 = execSync('mkdir -p ' + audiopath + hlos + '/' + type + '/', { encoding: 'utf-8' });  // the default is 'buffer'
    console.log('--- Output was:\n', output1);

    const output2 = execSync('if [ ! -e ' + path + ' ]; then wget https://gaussia.de/slp-test/' + path + ' -O ' + path + '; fi', { encoding: 'utf-8' });  // the default is 'buffer'
    console.log('--- Output was:\n', output2);
   
    
    return path;
}

var numberWord0To9 = {
    0: "0",
    1: "1",
    2: "2",
    3: "3",
    4: "4",
    5: "5",
    6: "6",
    7: "7",
    8: "8",
    9: "9",
}

var numberWord10To19 = {

    10: "10",
    11: "11",
    12: "12",
    13: "13",
    14: "14",
    15: "15",
    16: "16",
    17: "17",
    18: "18",
    19: "19",
}
var numberWord20To90 = {
    2: "20",
    3: "30",
    4: "40",
    5: "50",
    6: "60",
    7: "70",
    8: "80",
    9: "90",
    0: ""
}

var numberWord100To900 = {
    1: "100",
    2: "200",
    3: "300",
    4: "400",
    5: "500",
    6: "600",
    7: "700",
    8: "800",
    9: "900",
}

var numberHourWord1To24 = {
    1: "1",
    2: "2",
    3: "3",
    4: "4",
    5: "5",
    6: "6",
    7: "7",
    8: "8",
    9: "9",
    0: "0",
    10: "10",
    11: "11",
    12: "12",
    13: "13",
    14: "14",
    15: "15",
    16: "16",
    17: "17",
    18: "18",
    19: "19",
    20: "20",
    21: "21",
    22: "22",
    23: "23",
    24: "24",
}

function spellNumber1to99(num) {
    //let ret="";
    console.log("spellNumber1to99() = <" + num + "> " + " typeof " + typeof num);
    if (num < 0 || num > 1000) {
        return [{ audio: "misc/error", text: "error" }];
    }
    if (num < 10) {
        return [{ audio: "num/" + numberWord0To9[num], text: "" + num }];
    }
    else if (num >= 10 && num < 20) {
        return [{ audio: "num/" + numberWord10To19[num], text: "" + num }];

    }
    else if (num >= 20 && num < 100) {
        var num1 = Math.floor(num / 10);
        var num2 = num % 10;
        if (num2 == 0) {
            return [{ audio: "num/" + numberWord20To90[num1], text: "" + num1 + "0" }];

        }
        else {
            let audioA = [];
            audioA.push({ audio: "num/" + numberWord0To9[num2], text: "" + num2 });
            audioA.push({ audio: "misc/a", text: "a" });
            audioA.push({ audio: "num/" + numberWord20To90[num1], text: "" + num1 + "0" });
            return audioA;

        }
    }
}


function spellNumber(num) {
    console.log("number() = <" + num + ">" + " typeof " + typeof num);
    if (num < 0 || num >= 1000 || num == NaN) {
        let audio = [{ audio: "misc/error", text: "error" }];
        return audio;
    }


    if (num < 100) {
        return spellNumber1to99(num);
    }
    else if (num >= 100 && num < 1000) {

        let audioA = [];

        num1 = Math.floor(num / 100);
        num2 = num % 100;
        console.log(num1);
        console.log(num2);
        audioA.push({ audio: "num/" + numberWord100To900[num1], text: "" + num1 + "00" });
        //return audioA;
        if (num2 > 0)
            audioA = audioA.concat(spellNumber1to99(num2));
        //console.log("audioA: "+audioA);
        return audioA;
    }

}

function spellTime() {

    let hlos = 2;
    //let hlosEl = document.getElementById("hlos");
    //if (hlosEl != null)
    //    hlos = hlosEl.value;

    // let spellTextArea = document.getElementById("spelltextarea");
    let spellTextArea = true;
    
    let zeit = new Date;
    let hours = zeit.getHours();
    let min = zeit.getMinutes();


    let h12_24 = true;
    console.log("h12_24: " + h12_24);
    if (!h12_24 && hours > 12)
        hours -= 12;

    console.log("hours: " + hours + " min: " + min);
    let audioA = [];
    //for (let hours=0; hours<24;++hours){

    if (hours > 0 && hours <= 12)
        audioA.push({ audio: "hour/" + numberHourWord1To24[hours], text: "" + hours });
    else
        audioA = audioA.concat(spellNumber(hours));

    audioA.push({ audio: "misc/hodzin", text: "hodźin" });


    audioA = audioA.concat(spellNumber(min));

    //}

    playAudioA(audioA, hlos, spellTextArea);
}

function spellNumberText(numText, hlos, spellEl) {
    let audio = null;
    if (numText == null || numText == '') {
        audio = [{ audio: "misc/error", text: "error" }];
    } else {
        let num = parseInt(numText);
        audio = spellNumber(num);
    }
    playAudioA(audio, hlos, spellEl);
}

function playAudioA(audio, hlos, spellEl) {
	const execSync = require('child_process').execSync;
    let audioA = [];
    console.log("processing... ");

    for (let i = 0; i < audio.length; ++i) {
        console.log(i + ": " + audio[i]);
        let typeKeyA = audio[i].audio.split("/");
        let type = typeKeyA[0];
        let key = typeKeyA[1];
        console.log("type: " + type + " key: " + key);
        audioA.push(getaudio(key, type, hlos));
    }
    // spellEl.innerHTML = "";
    let curaudio = null;
    //let curindex=0;
    for (let i = 0; i < audioA.length; ++i) {
        curaudio = audioA[i];
        
        const output = execSync('mplayer -ao alsa:device=hw=U0x19080x332a ' + audioA[i], { encoding: 'utf-8' });  // the default is 'buffer'
        console.log('--- Output was:\n', output);
        
        //curaudio.onended = function () {
          //  if (i < audioA.length - 1) {
                // spellEl.innerHTML += audio[i + 1].text + " ";
                // audioA[i + 1].play();
                // var exec = require('child_process').exec;
            //}
        //}
    }
    // spellEl.innerHTML += audio[0].text + " ";
    // audioA[0].play();
}


function spellNum() {
    let numText = document.getElementById("textfield").value;
    let spellTextArea = document.getElementById("spelltextarea");
    let hlos = 1;
    let hlosEl = document.getElementById("hlos");
    if (hlosEl != null)
        hlos = hlosEl.value;
    //console.log("spellTextArea: "+spellTextArea);
    spellNumberText(numText, hlos, spellTextArea);
}

spellTime();
