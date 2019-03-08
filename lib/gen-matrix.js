#!/env/node
// Generate a matrix of experiments

const fs = require('fs');
const path = require('path');
const BINARY_EXTENSIONS = [
    '.hdt',
    '.hdt.index.v1-1'
];

function printUsage() {
    console.error(`Usage: comunica-bencher gen-matrix matrix-file experiment-template experiment-basename
    matrix-file         A file with matrix parameters.
    experiment-template An experiment template.`);
    process.exit(1);
}

function copyFileSync(source, target, replacements) {
    var targetFile = target;

    // If target is a directory a new file with the same name will be created
    if (fs.existsSync(target)) {
        if (fs.lstatSync(target).isDirectory()) {
            targetFile = path.join(target, path.basename(source));
        }
    }

    if (BINARY_EXTENSIONS.some((extension) => source.endsWith(extension))) {
        fs.createReadStream(source, { flags: 'r', encoding: "binary" })
            .pipe(fs.createWriteStream(targetFile, { flags: 'w', encoding: "binary" }));
    } else {
        let contents = fs.readFileSync(source, 'utf8');
        if (path.basename(source) === '.env') {
            contents = contents.replace(/^EXPERIMENT_NAME=.*/, 'EXPERIMENT_NAME=' + replacements['MATRIX_EXPERIMENT_NAME']);
        }
        for (replacementsKey in replacements) {
            contents = contents.replace(new RegExp('%' + replacementsKey + '%', 'g'), replacements[replacementsKey]); 
        }
        fs.writeFileSync(targetFile, contents);
    }
}

function copyFolderRecursiveSync(source, target, replacements) {
    var files = [];

    // Check if folder needs to be created or integrated
    const targetFolder = target;
    if (!fs.existsSync(targetFolder)) {
        fs.mkdirSync(targetFolder);
    }

    // Copy
    if (fs.lstatSync(source).isDirectory()) {
        files = fs.readdirSync(source);
        files.forEach((file) => {
            const curSource = path.join(source, file);
            if (fs.lstatSync(curSource).isDirectory() ) {
                copyFolderRecursiveSync(curSource, path.join(targetFolder, file), replacements);
            } else {
                copyFileSync(curSource, targetFolder, replacements);
            }
        });
    }
}

if (process.argv.length < 5) {
    printUsage();
}

matrix=process.argv[2];
template=process.argv[3];
experimentBasename=process.argv[4];
matrixNames=process.argv[5];

// Check if the matrix file exists
if (!fs.existsSync(matrix)) {
    console.error('The given matrix file could not be found.');
}

// Check if the experiment template is valid
if (!fs.existsSync(template)) {
    console.error('The given template file could not be found.');
}

// Calculate all matrix combinations
let combinations = [{}];
const matrixData = JSON.parse(fs.readFileSync(matrix));
for (let key in matrixData) {
    const values = matrixData[key];
    const combinationsCopies = [];
    for (let value of values) {
        // Make a copy of the combinations array
        const combinationsCopy = combinations.map((data) => ({ ...data }));
        combinationsCopies.push(combinationsCopy);
        
        // Set the value in all copies
        for (let combinationCopy of combinationsCopy) {
            combinationCopy[key] = value;
        }
    }
    // Update the current combinations
    combinations = combinationsCopies.reduce((acc, val) => acc.concat(val), []);
}

// Configure the combination names
if (fs.existsSync(matrixNames)) {
    const matrixNameData = JSON.parse(fs.readFileSync(matrixNames));
    if (!Array.isArray(matrixNameData) || matrixNameData.length !== combinations.length) {
        throw new Error(`Matrix combination names in ${matrixNames} should be an array of length ${combinations.length}.`);
    }
    for (var i = 0; i < combinations.length; i++) {
        const combination = combinations[i];
        combinations[i]['MATRIX_EXPERIMENT_NAME'] = matrixNameData[i];
    }
} else {
    for (var i = 0; i < combinations.length; i++) {
        const combination = combinations[i];
        combinations[i]['MATRIX_EXPERIMENT_NAME'] = experimentBasename + i;
    }
}

// Instantiate the combinations
console.log(`Generating combinations: ${combinations.length}`);
console.log('| | ' + Object.keys(matrixData).map((key) => `\`${key}\``).join(' | ') + ' |');
console.log('|-'.repeat(Object.keys(matrixData).length + 1) + '|');
for (var i = 0; i < combinations.length; i++) {
    const combination = combinations[i];
    console.log('| ' + experimentBasename + i + ' | ' + Object.keys(matrixData).map((key) => `\`${combination[key]}\``).join(' | ') + ' |');
    combinations[i]['MATRIX_ID'] = i;
    copyFolderRecursiveSync(template, experimentBasename + i, combination);
}
console.log('Done');
