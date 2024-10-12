export const constructPayload = (authorId,images) => {
    let fileNames =  getMappedFileNames(images);
    const payload = {
        roomUniqueId : authorId,
        fileNames  : fileNames
    }

    let jsonData = JSON.stringify(payload);
    let allImages = images.map(obj => Object.values(obj)).flat();

    const formData = new FormData();
    
    allImages.map(i=> {
        formData.append('file', i);
    })
    formData.append('jsonData', jsonData);

    return formData

}


export const getMappedFileNames = (images) => {
    console.log("File Names Array");
    let fileNames = {};
    images.map(({markerImg , modelImg}) => {
        let markerName = markerImg.name;
        let modelName = modelImg.name;
        fileNames = {...fileNames , 
            [markerName] : modelName
        }
    });
    return fileNames;   
}