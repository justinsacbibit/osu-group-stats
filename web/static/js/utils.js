export function getModsArray(curMods) {
  const modMap = [
    ['NF', 1],
    ['EZ', 2],
    ['HD', 8],
    ['HR', 16],
    ['SD', 32],
    ['DT', 64],
    ['RX', 128],
    ['HT', 256],
    ['NC', 512], // Only set along with DoubleTime. i.e: NC only gives 576
    ['FL', 1024],
    ['AP', 2048],
    ['SO', 4096],
    ['PF', 16384],
    // Where is SD?
  ];

  const mods = [];
  for (let i = modMap.length - 1; i >= 0; i--) {
    const arr = modMap[i];
    const [mod, val] = arr;
    if (val > curMods) {
      continue;
    }
    curMods -= val;
    if (val === 512) {
      curMods -= 64;
    }
    mods.push(mod);
  }

  return mods;
}

