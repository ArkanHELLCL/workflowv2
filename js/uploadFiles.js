/*
 * Variables
 */

let filesList = [];
const classDragOver = "drag-over";
//const fileInputMulti = document.querySelector("#multi-selector-uniq #files");
// DEMO Preview
//const multiSelectorUniqPreview = document.querySelector("#multi-selector-uniq #preview");

/*
 * Functions
 */

/**
 * Returns the index of an Array of Files from its name. If there are multiple files with the same name, the last one will be returned.
 * @param {string} name - Name file.
 * @param {Array<File>} list - List of files.
 * @return number
 */
function getIndexOfFileList(name, list) {    
    return list.reduce(
        (position, file, index) => (file.name === name ? index : position),
        -1
    );
}

/**
 * Returns a File in text.
 * @param {File} file
 * @return {Promise<string>}
 */
async function encodeFileToText(file) {
    return file.text().then((text) => {
        return text;
    });
}

/**
 * Returns an Array from the union of 2 Arrays of Files avoiding repetitions.
 * @param {Array<File>} newFiles
 * @param {Array<File>} currentListFiles
 * @return Promise<File[]>
 */
async function getUniqFiles(newFiles, currentListFiles) {
    return new Promise((resolve) => {
        Promise.all(newFiles.map((inputFile) => encodeFileToText(inputFile))).then(
            (inputFilesText) => {
                // Check all the files to save
                Promise.all(
                    currentListFiles.map((savedFile) => encodeFileToText(savedFile))
                ).then((savedFilesText) => {
                    let newFileList = currentListFiles;
                    inputFilesText.forEach((inputFileText, index) => {
                        if (!savedFilesText.includes(inputFileText)) {
                            newFileList = newFileList.concat(newFiles[index]);
                        }
                    });
                    resolve(newFileList);
                });
            }
        );
    });
}

/**
 * Only DEMO. Render preview.
 * @param currentFileList
 * @Only .EMO> param target.
 * @
 */
function renderPreviews(currentFileList, target, inputFile) {
    target.style.display = "grid";
    target.textContent = "";
    currentFileList.forEach((file, index) => {        
        const myLi = document.createElement("li");
        myLi.textContent = file.name;
        myLi.setAttribute("draggable", 'true');
        myLi.dataset.key = file.name;
        //myLi.addEventListener("drop", eventDrop);
        myLi.addEventListener("drop", (e) => eventDrop(e, inputFile, target));
        //myLi.addEventListener("dragover", eventDragOver);
        myLi.addEventListener("dragover", (e) => eventDragOver(e, target));
        const myButtonRemove = document.createElement("button");
        //myButtonRemove.textContent = "<i class='fas fa-trash'></i>";
        myButtonRemove.innerHTML = "<i class='fas fa-trash'></i>";
        myButtonRemove.addEventListener("click", () => {
            filesList = deleteArrayElementByIndex(currentFileList, index);
            inputFile.files = arrayFilesToFileList(filesList);
            //return renderPreviews(filesList, multiSelectorUniqPreview, inputFile);
            return renderPreviews(filesList, target, inputFile);
        });
        myLi.appendChild(myButtonRemove);
        target.appendChild(myLi);
    });
}

/**
 * Returns a copy of the array by removing one position by index.
 * @param {Array<any>} list
 * @param {number} index
 * @return {Array<any>} list
 */
function deleteArrayElementByIndex(list, index) {
    return list.filter((item, itemIndex) => itemIndex !== index);
}

/**
 * Returns a FileLists from an array containing Files.
 * @param {Array<File>} filesList
 * @return {FileList}
 */
function arrayFilesToFileList(filesList) {
    return filesList.reduce(function (dataTransfer, file) {        
        dataTransfer.items.add(file);
        return dataTransfer;
    }, new DataTransfer()).files;
}


/**
 * Returns a copy of the Array by swapping 2 indices.
 * @param {number} firstIndex
 * @param {number} secondIndex
 * @param {Array<any>} list
 */
function arraySwapIndex(firstIndex, secondIndex, list) {
    const tempList = list.slice();
    const tmpFirstPos = tempList[firstIndex];
    tempList[firstIndex] = tempList[secondIndex];
    tempList[secondIndex] = tmpFirstPos;
    return tempList;
}

/*
 * Events
 */

// Input file
export function eventFileInputMulti(inputFileId, listFilesId, dropZoneId) {    
    const fileInputMulti = document.querySelector(inputFileId);
    const multiSelectorUniqPreview = document.querySelector(listFilesId);    
    //removiendo el event listener anterior
    fileInputMulti.removeEventListener("input", async () => {
        // Get files list from <input>
        const newFilesList = Array.from(fileInputMulti.files);
        // Update list files
        filesList = await getUniqFiles(newFilesList, filesList);
        // Only DEMO. Redraw
        renderPreviews(filesList, multiSelectorUniqPreview, fileInputMulti);
        // Set data to input
        fileInputMulti.files = arrayFilesToFileList(filesList);
    });
    // Para el evento click del input file
    fileInputMulti.addEventListener("input", async () => {
        // Get files list from <input>
        const newFilesList = Array.from(fileInputMulti.files);
        // Update list files
        filesList = await getUniqFiles(newFilesList, filesList);
        // Only DEMO. Redraw
        renderPreviews(filesList, multiSelectorUniqPreview, fileInputMulti);
        // Set data to input
        fileInputMulti.files = arrayFilesToFileList(filesList);
    });

    //DropZone
    initApp(dropZoneId, multiSelectorUniqPreview, fileInputMulti)
}

// Drop Zone
function initApp(dropZoneId, multiSelectorUniqPreview, fileInputMulti){
    const droparea = document.querySelector(dropZoneId);
    const active = () => droparea.classList.add("green-border");
    const inactive = () => droparea.classList.remove("green-border");
    const prevents = (e) => e.preventDefault();

    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(evtName => {
        droparea.removeEventListener(evtName, prevents);
        droparea.addEventListener(evtName, prevents);
    });

    ['dragenter', 'dragover'].forEach(evtName => {
        droparea.removeEventListener(evtName, active);
        droparea.addEventListener(evtName, active);
    });

    ['dragleave', 'drop'].forEach(evtName => {        
        droparea.removeEventListener(evtName, inactive);
        droparea.addEventListener(evtName, inactive);
    });
    droparea.removeEventListener("drop", (e) => handleDrop(e, multiSelectorUniqPreview, fileInputMulti));    
    droparea.addEventListener("drop", (e) => handleDrop(e, multiSelectorUniqPreview, fileInputMulti));
}

const handleDrop = async (e, multiSelectorUniqPreview, fileInputMulti) => {
    const dt = e.dataTransfer;
    const files = dt.files;

    // Get files list from DropZone
    const newFilesList = Array.from(files);
    // Update list files
    filesList = await getUniqFiles(newFilesList, filesList);
    renderPreviews(filesList, multiSelectorUniqPreview, fileInputMulti);
    // Set data to input
    fileInputMulti.files = arrayFilesToFileList(filesList);
}
// Drop Zone


// Drag and drop
// Drag Start - Moving element.
let myDragElement = undefined;
document.addEventListener("dragstart", (event) => {
    // Saves which element is moving.
    myDragElement = event.target;
});

// Drag over - Element that is below the element that is moving.
function eventDragOver(event, target) {    
    // Remove from all elements the class that will show that it is a drop zone.
    event.preventDefault();
    //multiSelectorUniqPreview
    target
        .querySelectorAll("li")
        .forEach((item) => item.classList.remove(classDragOver));

    // On the element above it, the class is added to show that it is a drop zone.
    event.target.classList.add(classDragOver);
}

// Drop - Element on which it is dropped.
function eventDrop(event, fileInput, target) {
    // The element that is underneath the element that is moving when it is released is captured.
    let myDropElement = event.target;    
    // The positions of the elements in the array are swapped. The dataset key is used as an index.    
    // Si el elemento no tiene dataset o no tiene key, se busca el padre.
    if(myDropElement.dataset===undefined || myDropElement.dataset.key===undefined){
        myDropElement = myDropElement.parentElement;
    }
    // Si el elemento no tiene dataset o no tiene key, se sale.
    if(myDropElement.dataset===undefined || myDropElement.dataset.key===undefined) return
    filesList = arraySwapIndex(
        getIndexOfFileList(myDragElement.dataset.key, filesList),
        getIndexOfFileList(myDropElement.dataset.key, filesList),
        filesList
    );
    // The content of the input file is updated.
    //fileInputMulti.files = arrayFilesToFileList(filesList);
    fileInput.files = arrayFilesToFileList(filesList);
    // Only DEMO. Changes are redrawn.
    //renderPreviews(filesList, multiSelectorUniqPreview, fileInputMulti);
    return renderPreviews(filesList, target, fileInput);
}