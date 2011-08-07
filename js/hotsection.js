jQuery(function($){

Module('nz.geek.fox',function(m){

  Joose.Managed.Attribute.meta.extend({
        does : [ JooseX.Attribute.Lazy ]
  });

Class("ContentBox", {
  has: {
    parentNode: { isa: 'Str', is: 'ro', required: 1 },
    container : { isa: 'Obj', is: 'rw', predicate: 'hasContainer', lazy: '_buildContainer'},
    content   : { isa: 'Obj', is: 'rw', predicate: 'hasContent', lazy: '_buildContent' },
    populate  : { is: 'rw', required: 1 }
  },
  methods: {
    _buildContainer: function(){
      var object = document.createElement('div');
      $(object).addClass('content');
      $( this.getParentNode() ).append($(object));
      return $(object);
    },
    _buildContent: function() {
      var populate = this.getPopulate();
      $( this.getContainer() ).append(
        populate( this.getContainer() )
      );
    },
    hide: function(){
      $( this.getContainer() ).slideUp('fast');
    },
    show: function(){
      this.getContent();
      $( this.getContainer() ).slideDown('fast');
    },
    emptyContainer: function(){
      this.getContainer().empty();
      return this.getContainer();
    },
    loadContent: function( link , callback ){
      this.getContainer().load( link, function(){
        callback(this);    
      });
    }
  }
});

Class("HotSection", {

    has: {
      title: { isa: 'Str', is: 'ro', required: 1},
      link: { isa: 'Str', is: 'ro', required: 1},
      node: { isa: 'Obj', is: 'ro', required: 1},
      content: { isa: 'Obj', is: 'rw' , lazy: '_buildContent' }
    },
    after: {
      initialize: function (props) {
        var hs = this;
        $(this.node).find("div.link").remove();
        $(this.node).children('.name').each(function(i,o){ 
          var a  = $(document.createElement('a')).attr('href',hs.link);
          a.click(function(event){ return false; });
          $(o).wrapInner(a);
        });

       $(this.node).toggle(function(){
          hs.fullmode();
        },function(){ 
          hs.barmode();
        });
      }
    },
    methods:{
      _buildContent: function(){
        var hs = this;
        return new nz.geek.fox.ContentBox({
          parentNode: hs.getNode(),
          populate: function( obj ){ 
            obj.load( hs.getLink() );
            return "<span>Loading</span>";
          }
        });
      },
      fullmode: function(){ 
        this.getContent().show();
        $( this.node ).children().not('div.content').slideUp('fast');
        // history.pushState( { path: this.getLink() } , this.getTitle(), this.getLink() );
      },
      barmode: function(){ 
        $( this.node ).children().not('div.content').slideDown("fast");
        this.getContent().hide();
        // history.pushState( { path: '/' } , 'Kent Fredric\'s Projects on Github', '/' );
      }
    }
});

});

$('div.crossref').each(function(i,o){
    o.HotSection = new nz.geek.fox.HotSection({
      title: $(o).find("div.name").text(),
      link: $(o).find("div.link a:eq(0)").attr('href'),
      node: o
    });
});

});

