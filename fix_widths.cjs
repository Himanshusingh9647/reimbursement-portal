const fs = require('fs');
const path = require('path');

function processDir(dir) {
    const entries = fs.readdirSync(dir, { withFileTypes: true });
    for (const entry of entries) {
        const fullPath = path.join(dir, entry.name);
        if (entry.isDirectory()) {
            processDir(fullPath);
        } else if (entry.isFile() && fullPath.endsWith('.jsx')) {
            let content = fs.readFileSync(fullPath, 'utf8');
            let modified = false;

            // 1. Replace max-w-[1600px] with max-w-none
            if (content.includes('max-w-[1600px]')) {
                content = content.replace(/max-w-\[1600px\]/g, 'max-w-none');
                modified = true;
            }

            // 2. Replace grid-cols-12 with flex
            if (content.includes('lg:grid-cols-12')) {
                content = content.replace(
                    /className="grid grid-cols-1 lg:grid-cols-12 ([^"]+)"/g,
                    'className="flex flex-col lg:flex-row $1"'
                );
                modified = true;
            }

            // 3. Replace lg:col-span-8 with flex-1
            if (content.includes('lg:col-span-8')) {
                content = content.replace(
                    /className="lg:col-span-8 ([^"]+)"/g,
                    'className="flex-1 min-w-0 $1"'
                );
                modified = true;
            }

            // 4. Replace lg:col-span-4 with fixed width
            if (content.includes('lg:col-span-4')) {
                content = content.replace(
                    /className="lg:col-span-4 ([^"]+)"/g,
                    'className="w-full lg:w-[360px] shrink-0 $1"'
                );
                modified = true;
            }

            if (modified) {
                fs.writeFileSync(fullPath, content, 'utf8');
                console.log(`Modified: ${fullPath}`);
            }
        }
    }
}

processDir(path.join(__dirname, 'src', 'pages'));
console.log('Done.');
