const initials = function(item) {
    const names = item.split(' ');
    const namesOfInterest = [names[0], names[names.length - 1]];
    const initials = namesOfInterest.map((item) => item[0]);

    let assembledInitials = "";
    initials.map((item) => {
        assembledInitials = assembledInitials.concat(item);
    });
    
    return assembledInitials;
}

export default initials;