// Sobe o protótipo em http://localhost:8080 (build release, tela de design).
// Funciona em macOS, Linux e Windows: usa o Flutter da versão do .fvmrc
// em ~/fvm/versions/<versão> e, se não achar, o `flutter` do PATH.
// Chamado pelo .claude/launch.json ("design-preview").
import { spawn } from "node:child_process";
import { existsSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const appDir = join(dirname(fileURLToPath(import.meta.url)), "..");
const isWin = process.platform === "win32";

const { flutter: version } = JSON.parse(readFileSync(join(appDir, ".fvmrc"), "utf8"));
const fvmFlutter = join(homedir(), "fvm", "versions", version, "bin", isWin ? "flutter.bat" : "flutter");
const flutter = existsSync(fvmFlutter) ? fvmFlutter : "flutter";

const args = [
  "run", "-d", "web-server", "--release",
  "-t", "lib/main_design.dart",
  "--web-hostname", "localhost", "--web-port", "8080",
];

console.log(`[run_web] ${flutter} ${args.join(" ")}`);

const opts = { cwd: appDir, stdio: ["ignore", "inherit", "inherit"] };
// .bat no Windows precisa de shell: comando numa string só, caminho entre aspas
// (os args são fixos, nada vindo de fora).
const child = isWin
  ? spawn(`"${flutter}" ${args.join(" ")}`, { ...opts, shell: true })
  : spawn(flutter, args, opts);

for (const sig of ["SIGINT", "SIGTERM"]) process.on(sig, () => child.kill(sig));
child.on("exit", (code) => process.exit(code ?? 0));
