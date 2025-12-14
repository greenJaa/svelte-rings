<script>
import { onMount } from "svelte";
import { initializeApp } from "firebase/app";
import { getAuth, signInWithRedirect, GoogleAuthProvider, signOut, onAuthStateChanged } from "firebase/auth";
import { getFirestore, doc, getDoc, setDoc } from "firebase/firestore";

// Import the functions you need from the SDKs you need
import { getAnalytics } from "firebase/analytics";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY,
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID,
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID,
  appId: import.meta.env.VITE_FIREBASE_APP_ID,
  measurementId: import.meta.env.VITE_FIREBASE_MEASUREMENT_ID
};


// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app); 

//console.log(import.meta.env.VITE_FIREBASE_API_KEY);
//console.log(import.meta.env); // shows all exposed variables

//const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getFirestore(app);

let user = null;

// --- Authentication ---
function login() {
    const provider = new GoogleAuthProvider();
    signInWithRedirect(auth, provider);
}

function logout() {
    signOut(auth);
}

// --- Firestore persistence ---
async function saveToFirestore() {
    if (!user) return;

    const userRef = doc(db, "users", user.uid);
    await setDoc(userRef, {
        rhythms: rhythms.map(r => r.store()),
        instruments: Object.fromEntries(
            Object.entries(instruments).map(([k,v]) => [k,v.sym_list.map(s => s.description)])
        ),
        active,
        bpm
    });
    console.log("Saved to Firestore");
}

async function loadFromFirestore() {
    if (!user) return;
    const userRef = doc(db, "users", user.uid);
    const snapshot = await getDoc(userRef);
    if (snapshot.exists()) {
        const data = snapshot.data();
        if (data.rhythms) rhythms = data.rhythms.map(r => Rhythm.fromLoaded(r, instruments));
        if (data.instruments) {
            for (let name in data.instruments) {
                if (name in instruments) instruments[name].sym_list = data.instruments[name].map(desc => symbols[desc]);
            }
        }
        if (data.active) active = data.active;
        if (data.bpm) bpm = data.bpm;
        console.log("Loaded from Firestore");
    }
}

// Listen for auth changes on mount
onMount(() => {
    const unsubscribe = onAuthStateChanged(auth, async (u) => {
        user = u;
        if (user) await loadFromFirestore();
    });
    return () => unsubscribe();
});

// --- Reactive Firestore saving (debounced for performance) ---
let saveTimeout;
$: if (user) {
    clearTimeout(saveTimeout);
    saveTimeout = setTimeout(() => saveToFirestore(), 500); // save 0.5s after last change
}

// ------------------- existing App.svelte code below -------------------
// keep all your imports, instruments, rhythms, active, etc.
// just place this Firebase code above your existing code
    const VERSION = "0.3.0"

    if (localStorage.getItem("version") != VERSION) {
        localStorage.clear()
        localStorage.setItem("version", VERSION)
    }

    import Episode from "./episode.js"
    import Phrase from "./phrase.js"
    import Rhythm from "./rhythm.js"
    import Pulse from "./pulse.js"
    import Attack from "./attack.js"
    import Instrument from "./instrument.js"
    import Pointer from "./pointer.js"
    import { in_limits } from "./utils.js"
    import sounds from "./sounds.js"
    import * as symbols from "./symbols"
    import {arrange_episodes} from "./arrange.js"

    import Circle from "./circle.svelte"
    import EpisodeBar from "./episode_bar.svelte"
    import InstrumentBar from "./instrument_bar.svelte"
    import BpmSelect from "./bpm_select.svelte"
    import PlayButton from "./play_button.svelte"
    import RhythmMenu from "./rhythm_menu.svelte"
    import VolumeView from "./volume_view.svelte"

    import DebugLayer from "./debug_layer.svelte"

    let playing_attacks = new Map()

    let instruments = {
        clave:    new Instrument('clave', "#1f77b4", [{    sound: sounds.beat },
            { letter: 'h', sym: symbols.TRIAG,             sound: sounds.beat_high }]),
        shekere:  new Instrument('shekere', "#17becf", [{  sound: sounds.shake }]),
        kenkeni:  new Instrument("kenkeni", "#e39700", [{  sound: sounds.kenkeni }]),
        sungban:  new Instrument("sungban", "#ff7f0e", [{  sound: sounds.sangban },
            { letter: 'c', sym: symbols.QUAD,              sound: sounds.sangban_closed }]),
        dundunba: new Instrument("dundunba", "#d62728", [{ sound: sounds.dundunba }]),
        djembe:   new Instrument("djembe", "#2ca02c", [
            { letter: 'b', sym: symbols.TRAPEZ,            sound: sounds.djembe_base },
            { letter: 't', sym: symbols.DOT,               sound: sounds.djembe_tone },
            { letter: 's', sym: symbols.TRIAG,             sound: sounds.djembe_slap },
        ]),
        bass:     new Instrument('bass', "#8c564b", [
            { letter: 's', sym: symbols.DOT,               sound: sounds.sangban },
            { letter: 'c', sym: symbols.QUAD,              sound: sounds.sangban_closed },
            { letter: 'd', sym: symbols.TRAPEZ,            sound: sounds.dundunba },
            { letter: 'k', sym: symbols.TRIAG,             sound: sounds.kenkeni }]),
    }

    let instrument_order = new Map([
        [ instruments.clave,        0.0 ],
        [ instruments.shekere,      0.05 ],
        [ instruments.djembe,       0.3 ],
        [ instruments.bass,         0.6 ],
        [ instruments.kenkeni,      0.8 ],
        [ instruments.sungban,      0.92 ],
        [ instruments.dundunba,     1 ],
    ].sort((a, b) => a[1] - b[1]))

    let rhythms = [
        new Rhythm("tatata", 16, [
            new Episode([
                Phrase.fromPatterns(instruments.kenkeni,  ["..xx ..xx ..xx ..xx"]),
                Phrase.fromPatterns(instruments.djembe,   ["s..s s.tt s..s s.tt"])
            ]),
            new Episode([
                Phrase.fromPatterns(instruments.djembe,   ["bttt b.ss bttt b.ss"])
            ]),
        ]),
        new Rhythm("koreduga", 18, [
            new Episode([
                Phrase.fromPatterns(instruments.shekere,  ["x.. x.. x.. x.. x.. x.."]),
                Phrase.fromPatterns(instruments.bass,     ["d.d .d. d.d d.d .s. s.d"]),
                Phrase.fromPatterns(instruments.djembe,   ["s.b .tt s.b s.b stt s.b"])
            ]),
            new Episode([
                Phrase.fromPatterns(instruments.djembe,   ["ss. tt. tt. ss. tt. tt."])
            ]),
            new Episode([
                Phrase.fromPatterns(instruments.kenkeni,  ["xx. ... xx. ... xx. ..."]),
                Phrase.fromPatterns(instruments.djembe,   ["s.s btt bs. s.s btt bs."])
            ]),
        ]),
        new Rhythm("bepepe", 12, [
            new Episode([
                Phrase.fromPatterns(instruments.shekere,  ["x.. ... x.. ..."]),
                Phrase.fromPatterns(instruments.bass,     ["dks s.d ssk d.k"]),
                Phrase.fromPatterns(instruments.djembe,   ["s.t ..b stt .s."])
            ]),
            new Episode([
                Phrase.fromPatterns(instruments.djembe,   ["b.t tts b.t .s."])
            ]),
            new Episode([
                Phrase.fromPatterns(instruments.djembe,   ["ss. t.. ss. .bs", ".s. ts. btt .tt"], 1.3)
            ]),
        ]),
        new Rhythm("djole", 16, [
            new Episode([
                Phrase.fromPatterns(instruments.shekere,  ["x... x... x... x..."]),
            ], 2),
            new Episode([
                Phrase.fromPatterns(instruments.sungban,  ["c... x... c... x..."]),
                Phrase.fromPatterns(instruments.dundunba, ["x... .... x.x. ...."]),
            ]),
            new Episode([
                Phrase.fromPatterns(instruments.sungban,  []),
                Phrase.fromPatterns(instruments.dundunba, []),
                Phrase.fromPatterns(instruments.bass,     ["d... s... d.d. s..."]),
                Phrase.fromPatterns(instruments.kenkeni,  ["..xx ..xx ..xx ..xx"]),
            ]),
            new Episode([
                Phrase.fromPatterns(instruments.djembe,   ["tttt b... t.t. b..."]),
            ], 8),
            new Episode([
                Phrase.fromPatterns(instruments.kenkeni,  []),
                Phrase.fromPatterns(instruments.bass,     ["d.kk s.kk d.dk s.kk"]),
                Phrase.fromPatterns(instruments.djembe,   ["ttst tstt stts ttst", "tstt s.ss ttst tss."], 1.2),
            ]),
        ]),
        new Rhythm("balakulandjan", 16, [
            new Episode([
                Phrase.fromPatterns(instruments.shekere,  ["x... .... x... ...."]),
                Phrase.fromPatterns(instruments.kenkeni,  ["x... x... x... x..."]),
            ], 2),
            new Episode([
                Phrase.fromPatterns(instruments.sungban,  [".... .... ..x. x..."]),
                Phrase.fromPatterns(instruments.dundunba, ["x... ..x. x... ..x."]),
                Phrase.fromPatterns(instruments.kenkeni,  []),
            ]),
            new Episode([
                Phrase.fromPatterns(instruments.sungban,  []),
                Phrase.fromPatterns(instruments.dundunba, []),
                Phrase.fromPatterns(instruments.kenkeni,  ["x... x... x... x..."]),
                Phrase.fromPatterns(instruments.bass,     ["d... ..d. d.s. s.d."]),
            ]),
            new Episode([
                Phrase.fromPatterns(instruments.djembe,   ["b.tt ..st t.bs .bs."]),
            ], 8),
            new Episode([
                Phrase.fromPatterns(instruments.djembe,   ["b.ss .bss b.ss ttss", "b.ss .bss b.s. ttss"]),
            ], 2),
            new Episode([
                Phrase.fromPatterns(instruments.djembe,   ["ttst tstt s.ts tts.", "ttst tstt s.t. tts."]),
            ], 2),
            new Episode([
                Phrase.fromPatterns(instruments.djembe,   ["bsss ttss s... ss..", "bsss ttss s.s. sstt"]),
            ], 2),
            new Episode([
                Phrase.fromPatterns(instruments.djembe,   ["..ss .s.t t.s. ss.t", "t.ss .s.t t.s. sstt"]),
            ], 2),
        ]),
        new Rhythm("Moribayasa", 16, [
            new Episode([
                Phrase.fromPatterns(instruments.shekere,  ["x... x... x... x..."]),
                Phrase.fromPatterns(instruments.sungban,  ["x... c... c.x. x.x."]),
                Phrase.fromPatterns(instruments.dundunba, ["x... ..x. x... ..x."]),
            ]),
            new Episode([
                Phrase.fromPatterns(instruments.djembe,   ["b.tt b.s. b.tt b.s."]),
            ]),
            new Episode([
                Phrase.fromPatterns(instruments.djembe,   ["s.bs s.tt s.bs s.tt"]),
            ]),
        ]),
        new Rhythm("Soko", 12, [
            new Episode([
                Phrase.fromPatterns(instruments.shekere,  ["x.. ... x.. ..."]),
                Phrase.fromPatterns(instruments.bass,     ["s.. c.. c.d s.d"]),
            ], 4),
            new Episode([
                Phrase.fromPatterns(instruments.bass,     ["s.. c.d s.d s.d", "s.. c.. c.d s.d"]),
            ], 2),
            new Episode([
                Phrase.fromPatterns(instruments.bass,     ["s.. c.d ssd ssd", "s.. kk. c.d ssd"]),
            ]),
            new Episode([
                Phrase.fromPatterns(instruments.djembe,   ["st. b.s s.t tbs", "st. b.s s.t .ss"])
            ]),
        ]),


    ]

    rhythms.forEach(rhythm => rhythm.blocked = true)

    $: store_rhythms(rhythms)
    $: store_instruments(instruments)
    $: store_active(active)
    $: store_bpm(bpm)

    function store_rhythms(rhythms) {
        const stored = rhythms.map(rhythm => rhythm.store())
        console.log("storing rhythms")
        localStorage.setItem("rhythms", JSON.stringify(stored))
    }

    function store_instruments(instruments) {
        const stored = {}
        for (let name  in instruments) {
            stored[name] = instruments[name].sym_list.map(sym => sym.description)
        }
        console.log("storing instruments")
        localStorage.setItem("instruments", JSON.stringify(stored))
    }

    function load_instruments() {
        const loaded = JSON.parse(localStorage.getItem("instruments") || "{}")
        for (let name in loaded) {
            if (name in instruments) {
                instruments[name].sym_list = loaded[name].map(desc => symbols[desc])
            }
        }
    }

    function load_rhythms() {
        const loaded = JSON.parse(localStorage.getItem("rhythms") || "[]")
        const loaded_rhythms = loaded.map(rhythm => Rhythm.fromLoaded(rhythm, instruments))
        for (let loaded_rhythm of loaded_rhythms) {
            const rhythm_id = rhythms.findIndex(rhythm => rhythm.name == loaded_rhythm.name)
            if (rhythm_id != -1) {
                if (rhythms[rhythm_id].blocked) {
                    rhythms[rhythm_id].load_blocked(loaded_rhythm)
                    rhythms = rhythms
                } else {
                    rhythms[rhythm_id] = loaded_rhythm
                }
            } else {
                rhythms = [...rhythms, loaded_rhythm]
            }
        }
    }

    load_instruments()
    load_rhythms()



    function clone_episode() {
        if (rhythms[active.rhythm_id].blocked) return

        rhythms[active.rhythm_id].episodes.splice(active.episode_id + 1, 0,
            rhythms[active.rhythm_id].episodes[active.episode_id].clone())
        rhythms = rhythms
        activate_episode(active.episode_id + 1)
        selected_episodes = new Set()
    }

    function del_episodes() {
        if (rhythms[active.rhythm_id].blocked) return

        rhythms[active.rhythm_id].episodes = rhythms[active.rhythm_id].episodes.filter((episode, episode_id) => !selected_episodes.has(episode_id))
        activate_episode(Math.min(active.rhythm_id, rhythms[active.rhythm_id].episodes.length - 1))
        selected_episodes = new Set()
    }

    function set_repeat(repeat) {
        for (let episode_id of selected_episodes) {
            rhythms[active.rhythm_id].episodes[episode_id].repeat = repeat
        }
        selected_episodes = new Set()
    }

    function set_off(state) {
        for (let episode_id of selected_episodes) {
            rhythms[active.rhythm_id].episodes[episode_id].off = state
        }
        selected_episodes = new Set()
    }

    function set_solo() {
        for (const [episode_id, episode] of rhythms[active.rhythm_id].episodes.entries()) {
            episode.off = !selected_episodes.has(episode_id)
            rhythms[active.rhythm_id].episodes[episode_id] = episode
        }
        selected_episodes = new Set()
    }

    function instrument_switch(instrument) {
        if (instrument.sym_list.length > 1) {
            instrument.sym_list.push(instrument.sym_list.shift())
            instruments = instruments
        }
    }

    function add_instrument(instrument) {
        if (rhythms[active.rhythm_id].blocked) return

        const episode = rhythms[active.rhythm_id].episodes[active.episode_id]
        const {phrases, disabled_phrases} = episode
        let instrument_phrases = disabled_phrases.filter(p => p.instrument == instrument)

        if (instrument_phrases.length > 0) {
            episode.disabled_phrases = disabled_phrases.filter(p => p.instrument != instrument)
        } else {
            instrument_phrases = [Phrase.fromPeriod(instrument, rhythms[active.rhythm_id].period)]
        }

        episode.phrases = phrases.concat(instrument_phrases)
        rhythms = rhythms
    }

    function disable_instrument(instrument) {
        if (rhythms[active.rhythm_id].blocked) return

        const episode = rhythms[active.rhythm_id].episodes[active.episode_id]
        const {phrases, disabled_phrases} = episode
        const instrument_phrases = phrases.filter(p => p.instrument == instrument)
        episode.phrases = phrases.filter(p => p.instrument != instrument)
        episode.disabled_phrases = disabled_phrases.concat(instrument_phrases)
        rhythms = rhythms
    }

    let active = { rhythm_id: 0, episode_id: 0, pos: 0, phase: 0 }
    let started = { ts: 0, episode_id: 0, pos: 0, phase: 0 }
    let selected_episodes = new Set()
    let bpm = 90

    function store_active(active) {
        const stored = { rhythm_name: rhythms[active.rhythm_id].name, episode_id: active.episode_id }
        localStorage.setItem("active", JSON.stringify(stored))
    }

    function load_active() {
        const from_url = {rhythm_name: document.location.pathname.substring(1)}
        const loaded = JSON.parse(localStorage.getItem("active"))
        const fallback = {rhythm_name: "koreduga"}
        for (const variant of [from_url, loaded, fallback]) {
            if (!variant) continue
            const index = rhythms.findIndex(rhythm => rhythm.name.toUpperCase() == variant.rhythm_name.toUpperCase())
            if (index >= 0) {
                active.rhythm_id = index
                active.episode_id = variant.episode_id ?? 0
                flush_started(false)
                break
            }
        }
    }

    load_active()

    function store_bpm(bpm) {
        localStorage.setItem("bpm", bpm)
    }

    function load_bpm() {
        const loaded = localStorage.getItem("bpm")
        if (loaded) {
            bpm = +loaded
        }
    }

    load_bpm()

    const max_elapsed = 500

    let animation_requested = false
    function request_animation() {
        if (animation_requested) return
        animation_requested = true
        window.requestAnimationFrame(process)
    }

    function process(now) {
        animation_requested = false

        const rhythm = rhythms[active.rhythm_id]
        if (started.ts && rhythm.episodes.some(episode => episode.can_play)) {
            request_animation()
            let { episode_id, pos, phase } = started
            const beat_period = {9: 3, 12: 3, 16: 4, 18: 3}[rhythm.period] || 4
            const elapsed = (now - started.ts) * (bpm / 60) * beat_period * 0.001
            pos += elapsed
            phase += elapsed
            while (!rhythm.episodes[episode_id].can_play || phase >= rhythm.episode_duration(episode_id)) {
                if (rhythm.episodes[episode_id].can_play) {
                    phase -= rhythm.episode_duration(episode_id)
                }
                episode_id = (episode_id + 1) % rhythm.episodes.length
            }

            //console.log(`now=${now.toFixed(2)} elapsed=${(now - started.ts).toFixed(2)} elapsed_pos=${elapsed.toFixed(2)} pos=${pos.toFixed(2)} phase=${phase.toFixed(2)} episode_id=${episode_id}`)
            active.episode_id = episode_id
            active.pos = pos
            active.phase = phase

            const involved_episodes = rhythm.episodes.slice(0, active.episode_id + 1)
            const instrument_last_phrase =new Map(involved_episodes.flatMap((episode => episode.phrases.map(phrase => [phrase.instrument, phrase]))))
            const playing_phrases = Array.from(instrument_last_phrase.values())

            //let report = now.toFixed(2).padEnd(16, ' ') + (now - started.ts).toFixed(2).padEnd(8, ' ') + pos.toFixed(2).padStart(8, ' ')

            for (const phrase of playing_phrases) {
                const phrase_length = phrase.parts.length * rhythm.period
                for (const attack of phrase.get_attacks()) {
                    if (in_limits((phase - attack.phase) % phrase_length, -0.01, 0.5)
                        && (attack.played == undefined
                            || pos - attack.played > phrase_length - 0.95)) {
                        //report += phase.toFixed(2).padStart(8, ' ') + "=" + to_play[phrase_length].get(phase).toString().padEnd(6, ' ')
                        if (phrase.volume > 0 && attack.sym) {
                            phrase.instrument.play(attack.sym, phrase.volume)
                            add_attack(attack, now, active.episode_id, 0 /*phrase_id*/, 0 /*part_id*/)
                            // console.log(`rhythms[${active.rhythm_id}].episodes[${active.episode_id}] ${attack.phase} -> playing`)
                        }
                        attack.played = pos
                    }
                }
            }
            //console.log(report)
        }

        const elapsed_atacks = []
        let changed = false
        for (const [attack, {playing_start}] of playing_attacks) {
            const elapsed = now - playing_start
            if (elapsed < 0) continue

            changed = true
            if (elapsed > max_elapsed) {
                elapsed_atacks.push(attack)
                attack.power = undefined
                attack.self_shift = undefined
            } else {
                attack.power = 5 * Math.exp(-elapsed * 0.01)
                attack.self_shift = 0.04 * Math.exp(-elapsed * 0.01) * Math.sin(elapsed * (0.008 - 0.001 * elapsed / max_elapsed) * Math.PI * 2)
            }
        }
        elapsed_atacks.forEach(attack => remove_attack(attack))

        if (changed) {
            playing_attacks = playing_attacks
        }

        if (changed || playing_attacks.size > 0) {
            request_animation()
        }

    }


    function add_attack(attack, playing_start, episode_id, phrase_id, part_id) {
        playing_attacks.set(attack, {playing_start, episode_id, phrase_id, part_id})
        // console.log(`episodes[${episode_id}] ${attack.phase} -> playing count=${playing_attacks.size}`)
        playing_attacks = playing_attacks
    }

    function remove_attack(attack) {
        playing_attacks.delete(attack)
        // console.log(`${attack.phase} -> removed count=${playing_attacks.size}`)
        playing_attacks = playing_attacks
    }

    function get_attacks_by_episode(playing_attacks, episode_id) {
        const result = new Map()
        for( const [attack, entry] of playing_attacks) {
            if (entry.episode_id == episode_id) {
                result.set(attack, entry)
            }
        }
        return result
    }


    // $: process_pointer(pointer)

    function process_pointer(pointer) {
        const {episode_id, phrase_id, part_id} = pointer.last ?? {}
        if (episode_id == undefined || phrase_id == undefined || part_id == undefined) return
        const rhythm = rhythms[active.rhythm_id]
        const episode = rhythm.episodes[episode_id]
        const phrase = episode.phrases[phrase_id]
        const attacks = phrase.get_attacks(part_id)
        const now = performance.now()

        for (const attack of attacks) {
            if ((pointer.prev_phase != undefined && pointer.prev_phase < attack.phase && pointer.phase >= attack.phase)
                || (pointer.prev_phase == undefined && Math.abs(pointer.phase - attack.phase) < 0.4)) {
                if (phrase.volume > 0) {
                    phrase.instrument.play(attack.sym, phrase.volume)
                }
                add_attack(attack, now, episode_id, phrase_id, part_id)
                // console.log(pulse.phase, pulse.sym, now)
            }
        }

        if (playing_attacks.size > 0) {
            request_animation()
        }
    }

    let roi
    $: roi = {start_id: active.episode_id, end_id: active.episode_id + (started.ts ? 2 : 1)}

    let episode_arrangement = {}
    $: if (layout && playing_attacks) {
        const old_view = episode_arrangement.view || {start_id: 0, end_id: rhythms[active.rhythm_id].episodes.length}
        episode_arrangement = arrange_episodes(rhythms[active.rhythm_id].period, rhythms[active.rhythm_id].episodes, instrument_order, layout.parts.height / layout.parts.width, active.episode_id, old_view, roi)
    }

    // let pointer_episode_arrangement = undefined
    // $: if(episode_arrangement && pointer.start?.section == "right") {
    //     console.log(Array.from(pointer_episode_arrangement?.episodes?.values() ?? [])?.at(1)?.phrase_arrangement, Array.from(episode_arrangement.episodes.values()).at(1).phrase_arrangement)
    //     pointer_episode_arrangement = arrange_pointer_episodes(pointer_episode_arrangement ?? episode_arrangement, pointer.last)
    // }


    function flush_started(reset_phase = true) {
        if (reset_phase) {
            active.pos = active.pos + rhythms[active.rhythm_id].total_duration
            active.phase = 0
        }
        started.episode_id = active.episode_id
        started.pos = active.pos
        started.phase = active.phase
        if (started.ts) {
            started.ts = performance.now()
        }
    }

    function toggle_play() {
        if (started.ts) {
            started.ts = 0
            flush_started()
        } else {
            started.ts = performance.now() - 10
        }
        request_animation()
    }

    function activate_episode(episode_id) {
        active.episode_id = episode_id
        flush_started()
    }

    function activate_rhythm(rhythm_id) {
        rhythms[rhythm_id].touch()
        rhythms = rhythms
        active.rhythm_id = rhythm_id
        active.episode_id = 0
        active.phase = 0
        started.ts = 0
        flush_started()
    }

    function create_rhythm(period) {
        const name = gen_rhythm_name(`rhythm${period}-1`)
        rhythms = [...rhythms,
            new Rhythm(name, period, [
                new Episode([
                    Phrase.fromPatterns(instruments.shekere,
                        period == 16 ? ["x...x...x...x..."] : ["x..x..x..x.."])
                ])
            ])
        ]
        activate_rhythm(rhythms.length - 1)
    }

    function del_rhythm() {
        if (rhythms[active.rhythm_id].blocked) return

        rhythms.splice(active.rhythm_id, 1)
        rhythms = rhythms
        const reducer = (latest, rhythm, curr) =>
            rhythm.accessed > rhythms[latest].accessed ? curr : latest
        activate_rhythm(rhythms.reduce(reducer, 0))
    }

    function gen_rhythm_name(name) {
        let index = 1
        const res = name.match(/^(.*)-(\d+)$/)
        let prefix = name
        if (res) {
            prefix = res[1]
            index = +res[2]
        }
        while(true) {
            if (!rhythms.find(rhythm => rhythm.name == name)) {
                break
            }
            index++
            name = prefix + "-" + index
        }
        return name
    }

    function clone_rhythm() {
        const rhythm = rhythms[active.rhythm_id]
        let name = gen_rhythm_name(rhythm.name)
        rhythms = [...rhythms, rhythm.clone(name)]
        activate_rhythm(rhythms.length - 1)
    }

    let current_volume = 1.0
    let volume_visible = false

    function on_cirle_swipeend(e) {
        setTimeout(() => { volume_visible = false}, 300)
    }

    let pointer = new Pointer()

    function clamp(x, l1, l2) {
        return x < l1 ? l1 : x > l2 ? l2 : x
    }

    function on_cirle_swipe(e) {
        const {episode_id, phrase_id, pulse_id, dx, dy, dir } = e.detail
        if (dir == 'y') {
            const {volume} = rhythms[active.rhythm_id].episodes[episode_id].phrases[phrase_id]
            volume_visible = true
            current_volume = clamp(volume - dy * 0.01, 0, 2)
            rhythms[active.rhythm_id].episodes[episode_id].phrases[phrase_id].volume = current_volume
        }
    }

    function phrase_extra(phrase_id) {
        let parts = rhythms[active.rhythm_id].episodes[active.episode_id].phrases[phrase_id].parts
        parts = parts.length > 1 ? [parts[0]] : [parts[0], parts[0].map(pulse =>
            new Pulse(pulse.phase + rhythms[active.rhythm_id].period, pulse.sym))]
        rhythms[active.rhythm_id].episodes[active.episode_id].phrases[phrase_id].parts = parts
    }

    let debug_active = false

    let layout_width
    let layout_height
    $: layout = calc_layout(layout_width, layout_height)

    function calc_layout(layout_width, layout_height, settings = {}) {
        if (!layout_width) return

        const { vertical_margin = 8,
            horizontal_margin = 4,
            header_height = 52,
            vertical_circle_to_main = 0.55,
            max_vertical_layout_width = 1000,
            min_vertical_aspect_ratio = 1,
            min_horizontal_aspect_ratio = 0.4,
            title_height = 28,
            max_width = 1400,
            parts_to_list = 0.77,
            parts_top_bottom_margin = 4,
            button_height = 32,
            button_width = 48,
            button_gap = button_width/2,
            button_icon_size_to_height = 0.8 } = settings

        const section = (top, bottom, left = 0, right = layout_width,
            height = bottom - top, middle = (top + bottom) / 2,
            width = right - left, center = (left + right) / 2) => (
            {top, bottom, height, middle,
                left, right, width, center})

        const vertical = layout_width <= max_vertical_layout_width && layout_height > layout_width * min_vertical_aspect_ratio
        const max_horizontal_width = Math.min(layout_height / min_horizontal_aspect_ratio, layout_width, max_width)
        const expanded_horizontal_margin = vertical ? horizontal_margin : Math.max(horizontal_margin, (layout_width - max_horizontal_width) / 2)
        const inner = section(vertical_margin, layout_height - vertical_margin, expanded_horizontal_margin, layout_width - expanded_horizontal_margin)

        let header, circle, list
        if (vertical) {
            header = section(inner.top, header_height, inner.left, inner.right)
            const circle_height = Math.min((inner.height - header.height) * vertical_circle_to_main, inner.width * 0.8)
            circle = section(header.bottom, header.bottom + circle_height, inner.left, inner.right)
            list = section(circle.bottom, inner.bottom, inner.left, inner.right)
        } else {
            header = section(inner.top, header_height, inner.left, inner.left + inner.width * 0.45)
            circle = section(header.bottom, inner.bottom, inner.left, header.right)
            list = section(inner.top, inner.bottom, circle.right, inner.right - button_width)
        }
        circle.size = Math.min(circle.width, circle.height) * 0.95

        const title = section(
            header.middle - title_height / 2, header.middle + title_height / 2,
            header.center - title_height * 3, header.center + title_height * 3)

        const parts = section(list.top + parts_top_bottom_margin, list.bottom - parts_top_bottom_margin, list.center - list.width * parts_to_list / 2, list.center + list.width * parts_to_list / 2)

        const buttons = section(0, layout_height, layout_width - button_width, layout_width)
        const menu_button = section(header.middle - button_height/2, header.middle + button_height/2, buttons.left, buttons.right)
        menu_button.size = menu_button.height * button_icon_size_to_height
        const play_button = section(menu_button.bottom + button_gap, menu_button.bottom + button_gap + button_height, buttons.left, buttons.right)
        play_button.size = play_button.height * button_icon_size_to_height
        const bpm_button = section(play_button.bottom + button_gap, play_button.bottom + button_gap + button_height, buttons.left, buttons.right)
        bpm_button.size = bpm_button.height * button_icon_size_to_height
        const bpm_range = section(buttons.top + button_gap, buttons.bottom - button_gap, buttons.left - button_width, buttons.left - 4)

        const parts_transform = `translate(${parts.left}, ${parts.top}) scale(${parts.width})`

        return {header, circle, list, title, width: layout_width, height: layout_height, vertical, parts, buttons, menu_button, play_button, bpm_button, bpm_range, parts_transform}
    }

    function on_window_touch(e, start) {
        if (e.changedTouches.length != 1) {
            pointer.release(true)
            pointer = pointer
            return
        }
        const {pageX: x, pageY: y} = e.changedTouches[0]
        update_pointer(x, y, start)
    }

    function on_window_touchend(e, canceled) {
        pointer.release(canceled)
        pointer = pointer
    }

    function update_pointer(x, y, is_start) {
        if (!layout || !episode_arrangement) return

        // console.log(x, layout.parts.left, layout.parts.right, y, layout.parts.top, layout.parts.bottom)

        if (in_limits(y, layout.parts.top, layout.parts.bottom)) {
            const section = in_limits(x, layout.parts.left, layout.parts.right) ? "parts" : x > layout.parts.right ? "right" : "left"
            const radius = (y - layout.parts.top) / layout.parts.width
            const arrangments = Array.from(episode_arrangement.episodes.values())
            const episode_id = arrangments.findIndex(({start, end}) => in_limits(radius, start, end))
            const view_start_id = (episode_arrangement?.view?.start_id ?? 0)
            const pointer_episode_id = episode_id == -1 ? undefined : episode_id + view_start_id
            const {phrase_arrangement, start: episode_start} = arrangments[episode_id] ?? {}
            const phrase_id = phrase_arrangement?.findIndex(({start, end}) => in_limits(radius - episode_start, start, end))
            const pointer_phrase_id = phrase_id == -1 ? undefined : phrase_id
            const phrase_start = phrase_arrangement?.[phrase_id]?.start
            const part_id = Math.floor(radius - episode_start - phrase_start) / episode_arrangement.part_space
            const phase = (x - layout.parts.left) / layout.parts.width * rhythms[active.rhythm_id].period
            const pointer_phase = pointer_phrase_id == undefined ? undefined : phase
            pointer.move_to(is_start, section, radius, pointer_episode_id, pointer_phrase_id, part_id, phase, pointer_phase)
            pointer = pointer
            return
        }

        pointer.move_to(is_start, "outside")
        pointer = pointer
    }

</script>



<!-- Login/Logout UI -->


<!-- Login/Logout UI -->
{#if !user}
<button class="login-button" on:click={login}>Login with Google</button>
{:else}
<div class="login-button">
    Logged in as {user.displayName}
    <button class="logout-button" on:click={logout}>Logout</button>
</div>
{/if}
<!-- Your existing App.svelte UI goes here -->


<style>
.login-button {
    position: fixed;   /* Stay in one place even when scrolling */
    top: 10px;
    left: 10px;
    padding: 8px 16px;
    background-color: #1a73e8; /* Google blue */
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    font-weight: bold;
    box-shadow: 0 2px 4px rgba(0,0,0,0.3);
    z-index: 9999;    /* Very high, above everything */
}

.login-button:hover {
    background-color: #1669c1;
}

.logout-button {
    margin-left: 8px;
    background-color: #ea4335; /* red for logout */
    color: white;
    border: none;
    border-radius: 4px;
    padding: 4px 10px;
    cursor: pointer;
}

.logout-button:hover {
    background-color: #c23321;
}

main {
    margin: 8px 4px;
    flex-grow: 1;
    display: flex;
    flex-direction: column;
    min-height: 10px;
    border: 3px solid var(--theme-fg);
}

.title {
    position: fixed;
    display: flex;
    justify-content: center;
}

main > * {
    flex-shrink: 0;
}
article {
    position: relative;
    flex-grow: 1;
    flex-shrink: 1;
    min-height: 48px;
    display: flex;
    flex-direction: row;
    justify-content: center;
}

.instrument_container {
    position: fixed;
    top: 12px;
    height: 260px;
    width: 32px;
}
.version {
    position: fixed;
    right: 13%;
    top: 0;
    padding: 1px;
    font-family: monospace;
    line-height: 50%;
    font-weight: bold;
    font-size: 8pt;
}
.version.debug {
    text-shadow: 0px 0px 4px cyan;
}

</style>

<svelte:window bind:innerWidth={layout_width} bind:innerHeight={layout_height}
    on:touchstart={(e) => on_window_touch(e, true)}
    on:touchmove={(e) => on_window_touch(e, false)}
    on:touchend={(e) => on_window_touchend(e, false)}
    on:touchcancel={(e) => on_window_touchend(e, true)}/>

<DebugLayer active={debug_active} {layout} {pointer} {episode_arrangement} episodes={rhythms[active.rhythm_id].episodes}/>

{#if layout}
<main>
    {#each [layout.title] as {left, top, width, height}}
    <h1 class="title rhythm_name" style="left: {left}px; top: {top}px; width: {width}px; height: {height}px">{rhythms[active.rhythm_id].name}</h1>
    {/each}
    <article>
        <div><VolumeView value={current_volume} visible={volume_visible}/></div>
        <Circle {instrument_order} {layout} {episode_arrangement}
            episodes={rhythms[active.rhythm_id].episodes}
            active_episode_id={active.episode_id}
            period={rhythms[active.rhythm_id].period}
            phase={active.phase}
            playing={started.ts != 0}
            {pointer}
            {playing_attacks}
            bind:selected_episodes={selected_episodes}
            on:swipeend={on_cirle_swipeend}
            on:swipe={on_cirle_swipe}
            on:change={({detail: {episode_id}}) => activate_episode(episode_id)}
            on:scroll_to={({detail: id}) => {roi = {start_id: id, end_id: id + 1}}}/>
    </article>

    <div class="edge_button" style="position: fixed; width: {layout.bpm_button.width}px; top: {layout.bpm_button.top}px; left: {layout.bpm_button.left}px; height: {layout.bpm_button.height}px">
        <BpmSelect {layout} bind:value={bpm} on:change={() => flush_started(false)}/>
    </div>

    <div class="edge_button" style="position: fixed; width: {layout.play_button.width}px; top: {layout.play_button.top}px; left: {layout.play_button.left}px; height: {layout.play_button.height}px">
        <PlayButton size={layout.play_button.height} playing={started.ts != 0}
            on:toggle={() => toggle_play()}/>
    </div>

    <RhythmMenu {layout} {rhythms} active={active.rhythm_id}
        on:switch={(e) => activate_rhythm(e.detail.rhythm_id)}
        on:rename={(e) => rhythms[active.rhythm_id].name = e.detail.name}
        on:new={(e) => create_rhythm(e.detail.period)}
        on:del={()=> del_rhythm()}
        on:clone={() => clone_rhythm()}/>
</main>
{/if}
<!-- <div class="instrument_container">
    <InstrumentBar
    {instrument_order}
    {instruments}
    episode={rhythms[active.rhythm_id].episodes[active.episode_id]}
    blocked={rhythms[active.rhythm_id].blocked}
    on:switch={(e) => instrument_switch(e.detail.instrument)}
    on:add={(e) => add_instrument(e.detail.instrument)}
    on:disable={(e) => disable_instrument(e.detail.instrument)}
    on:extra={(e) => phrase_extra(e.detail.phrase_id)}/>
</div> -->

<div class="version" class:debug={debug_active} on:click={() => { debug_active = !debug_active }}>v{VERSION}</div>
