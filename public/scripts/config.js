requirejs.config({

  //baseUrl: '',

  deps: [
    "game.min"
  ],

  paths: {
    jquery: "../jquery/jquery.min",
    mustache: "../mustache/mustache",
    underscore: "../underscore/underscore-min",
    backbone: "../backbone/backbone-min",
    use: "../require/use.min"
  },

  use: {

    jquery: {
      attach: 'jQuery'
    },

    underscore: {
      attach: '_'
    },

    backbone: {
      deps: ["use!jquery", "use!underscore"],
      attach: "Backbone"
    },

    mustache: {
      attach: "Mustache"
    }

  }



});
