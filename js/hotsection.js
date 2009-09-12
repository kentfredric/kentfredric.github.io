jQuery(function($){


var createHotSection = function( node ){
  var hotsection = {};
  hotsection.link = $(node).find("div.link a:eq(0)").attr('href');
  hotsection.fullmode = function (){ 
    $(node).children().not('div.content').slideUp("fast");
  };
  hotsection.barmode = function() { 
    $(node).children().not('div.content').slideDown("fast");
  };
  hotsection.recreateContent = function() {
    $(node).find("div.content").remove();
    var content = $(document.createElement('div')).addClass('content');
    $(node).append( content );
    return content;
  };
  hotsection.updateContent = function() {
    var content = hotsection.recreateContent();
    content.load( hotsection.link, function(){ 
      content.children().click(function(event){ 
        event.stopPropagation();
      });;
    });
  };
  hotsection.setup = function(){ 
    $(node).find("div.link a:eq(0)").remove();
    $(node).children('.name').each(function(i,o){ 
      var a  = $(document.createElement('a')).attr('href',hotsection.link);
      a.click(function(event){ return false; });
      $(o).wrapInner(a);
    });
    $(node).toggle(function(){ 
      hotsection.fullmode();
      hotsection.updateContent();
    },function(){ 
      hotsection.barmode();
      $(node).children('div.content').slideUp('fast');
    });
  };
  return hotsection;

};


$('div.crossref').each(function(i,o){ 
    createHotSection(o).setup();
});

});

