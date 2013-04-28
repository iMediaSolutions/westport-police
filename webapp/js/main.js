requirejs.config({
    appDir: ".",
    baseUrl: "js",
    paths: { 
        /* Load jquery from google cdn. On fail, load local file. */
        'jquery': ['//ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min','vendors/jquery-min'],
        /* Load bootstrap from cdn. On fail, load local file. */
        'bootstrap': ['//netdna.bootstrapcdn.com/twitter-bootstrap/2.2.1/js/bootstrap.min',,'vendorswq/bootstrap-min']
    },
    shim: {
        /* Set bootstrap dependencies (just jQuery) */
        'bootstrap' : ['jquery']
    }
});

require([
    'jquery', 'bootstrap',
],
function($){
    console.log("Loaded :)");    
    return {};
});
