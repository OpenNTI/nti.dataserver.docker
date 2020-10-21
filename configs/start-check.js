const { execSync } = require('child_process');
const run = x => execSync(x, {stdio: 'pipe'}).toString('utf8').trim();

try {
	const image = run('docker images -q nti-dataserver') || false;

	const c = require('chalk');
	console.log(`nti-dataserver image exists: ${image ? c`{green ok}` : c`{red missing}`}\n`);

	if (!image) throw new Error('missing image');

} catch {
	console.error('Missing dependencies.');
	console.error('You may need to run: npm install.');
	process.exitCode = 1;
}
