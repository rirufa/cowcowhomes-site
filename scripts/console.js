hexo.extend.console.register( 'gzip', 'gzip content', function( args, callback) {
   var baseDir = hexo.base_dir;
   var zlib = require('zlib');
   var gzip = zlib.createGzip('level=9');
   var fs = require('fs');
   var log = this.log
   hexo.call('generate', function(err){
      if (err) return callback(err);
      log.info('Now gzipping files ...');
      var start = Date.now();
      var traverseFileSystem = function (currentPath) {
         var files = fs.readdirSync(currentPath);
         for (var i in files) {
            var currentFile = currentPath + '/' + files[i];
            var stats = fs.statSync(currentFile);
            if (stats.isFile()) {
               if(currentFile.match(/\.(ico|html|js|css|json|xml|ttf|eot|ott|woff|svg)$/)) {
                  var gzip = zlib.createGzip();
                  var inp = fs.createReadStream(currentFile);
                  var out = fs.createWriteStream(currentFile+'.gz');
                  inp.pipe(gzip).pipe(out);
                  log.info(currentFile+'.gz');
               }
            }
           else if (stats.isDirectory()) {
                  traverseFileSystem(currentFile);
                }
          }
        };
      traverseFileSystem(baseDir+'public');
      var finish = Date.now();
      var elapsed = (finish - start) / 1000;
      log.info('gzipped in '+elapsed+'s');
   });
});