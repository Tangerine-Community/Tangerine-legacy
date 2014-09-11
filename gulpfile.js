
/**
 * Include Gulp and the necessary plugins
 */
var gulp 		= require('gulp'); 

// general & process plugins 
var changed 	= require('gulp-changed');
var clean 		= require('gulp-clean');
var concat 		= require('gulp-concat');
var exec 		= require('child_process').exec;
var fs 			= require('fs');
var gulpif 		= require("gulp-if");
var gutil 		= require('gulp-util');
var inject 		= require('gulp-inject');
var merge 		= require('merge-stream');
var path 		= require('path');
var plumber 	= require('gulp-plumber');
var rename 		= require("gulp-rename");
var runSequence = require('run-sequence');
var size 		= require('gulp-size');
var sourcemaps 	= require('gulp-sourcemaps');
var useref 		= require('gulp-useref');
var watch 		= require('gulp-watch');

// script plugins
var coffee 		= require('gulp-coffee');
var coffeelint 	= require('gulp-coffeelint');
var cson 		= require('gulp-cson');
var uglify 		= require('gulp-uglify');

// style plugins
var less 		= require('gulp-less');
var minifyCSS 	= require('gulp-minify-css');

// image plugins
var imagemin 	= require('gulp-imagemin');

//couch plugins
var run 		= require("gulp-run"); // used to run the python couchapp build script (it's a better option than the current NPM ones)


/**
 * Define variables used in the build
 */

//src and destination paths to be used by the Gulp Tasks
var paths = {
	basePath: {
		src: 			'app',
		tmp: 			'.tmp',
		build: 			'dist'
	},
	coffee_scripts: {
		src_all: 		['app/**/*.coffee','!app/_attachments/js/lib/**/*.*', '!app/_attachments/locales/**/*.coffee'],
		src_locales: 	['app/_attachments/locales/**/*.coffee'], 
		dest_all: 		'.tmp/app',
		dest_locales: 	'dist/app/_attachments/locales'
	},
	app_scripts: {		//some src files are explicitly specified here to enforce order of including in the app.js
		src: 			['.tmp/app/_attachments/js/helpers.js', '.tmp/app/_attachments/js/modules/**/*.js', '.tmp/app/_attachments/js/{boot,helpers,router}.js', '.tmp/app/_attachments/js/version.js', '!.tmp/**/app.js', '!.tmp/**/vendor.min.js', '!.tmp/**/*.js.map'],
		src_version: 	'.tmp/app/_attachments/js/version.js',
		dest: 			'dist/app/_attachments/js'
	},
	vendor_scripts: {
		src_all: 		['app/_attachments/js/lib/**/*'],
		src_html: 		['app/_attachments/**/*.html'],
		dest_all: 		'dist/app/_attachments/js/lib/',
		dest_html: 		'dist/app/_attachments/',
		search_path: 	['dist/app/_attachments', '.tmp/app/_attachments', 'app/_attachments'], 
	},
	db_scripts: {
		src: 			['.tmp/app/{_docs,filters,lists,shows,views}/**/*.*'],
		dest: 			'dist'
	},
	styles: {
		src_less: 		['./app/_attachments/css/**/*.less'],
		src_other: 		['./app/_attachments/css/**/*.css', './app/_attachments/css/**/*.ttf'],
		dest: 			'dist/app/_attachments/css', 	
	},
	inject: {
		src_html: 		'dist/app/_attachments/**/*.html',
		dest_html: 		'dist/app/_attachments',
		src_js: 		['dist/app/_attachments/js/app.js', 'dist/app/_attachments/js/app.min.js'],
		src_css: 		['']
	},
	images: {
		src: 			['app/_attachments/**/*.{gif,png,jpeg,jpg,svg}','!app/_attachments/js/lib/**/*.*'],
		dest: 			'dist/app/_attachments'
	},
	html: {
		src: 			['app/**/*.html'], 
	},
	couchapp: {
		src: 			['app/*.*', 'app/.*', 'app/_id', 'app/_docs/*.*', '!app/{_attachments,filters,lists,shows,views}/**/*'],
		dest: 			'dist/app'
	}
};

// Define options for the gulp build process
var options = {
	isProd: false,
	doLint: true,
	isWatching: false,
	openBrowser: true
};

// Enable command-line overrides of options
options.isProd = (gutil.env.prod === true)? true : options.isProd;		//gulp --prod
options.doLint = (gutil.env.noLint === true)? false : options.doLint;	//gulp --noLint (defaults to perform linting)

//helper functoin to log any errors that are thrown
var handleError = function(error){
	gutil.log('Handling Error');
	gutil.log(error.message);
};

//helper function to display an intro message
var introMessage = function(taskName) {
	gutil.log(
		gutil.colors.blue(
			'\n*****************************************************'+ 
			'\n  Starting Gulp '+ taskName + ' Tasks for Tangerine'+
			'\n\n  Options:'+
			'\n        isProd: '+ options.isProd+
			'\n        doLint: '+ options.doLint+
			'\n*****************************************************'
		)
	);
};

//helper function to log the file changes
var logChange= function(event){
	gutil.log(gutil.colors.green('File ' + event.path + ' was ' + event.type + ', running tasks...'))
	'File ' + event.path + ' was ' + event.type + ', running tasks...'
};

// Helper function to execute a shell command
var execute = function(command, callback){
    exec(command, function(error, stdout, stderr){ callback(stdout); });
};


/**
 * Gulp Task: clean - deletes the tmp and build directories
 * @return {stream} gulp stream
 */
gulp.task('clean', function() {
	return gulp.src([paths.basePath.build, paths.basePath.tmp], {read: false})
    	.pipe(clean());
});

/**
 * Gulp Task: lint_coffee - optionally perform a lint operation on the .coffee files. 
 * 							lint params can be modified using the coffeelint.json file at the root
 * @return {stream} gulp stream
 */
gulp.task('lint_coffee', function() {
	var stream;
	if(options.doLint){
		stream = gulp.src(paths.coffee_scripts.src_all)
			.pipe( options.isWatching ? changed(paths.coffee_scripts.dest_all, { extension: '.js' }) : gutil.noop() ) //if watching, only lint changed files
			.pipe(coffeelint())
  			.pipe(coffeelint.reporter())
			.on('error', handleError);
	} else {
		stream = gulp.src(paths.coffee_scripts.src_all, {read: false})
			.pipe(gutil.noop());
	}
	return stream;
});

/**
 * Gulp Task: coffee - compile all coffeescript
 * @return {stream} gulp stream
 */
gulp.task('coffee', function() {
	return merge(

		//compile all coffee with the exception of the locale files
		gulp.src(paths.coffee_scripts.src_all)
			.pipe(changed(paths.coffee_scripts.dest_all, { extension: '.js' }))
			.pipe(sourcemaps.init())
				.pipe(coffee({bare: true}).on('error', handleError))
			.pipe(sourcemaps.write('.'))
			.pipe(gulp.dest(paths.coffee_scripts.dest_all)),

		//handle special situation for locales -> json files
		gulp.src(paths.coffee_scripts.src_locales)
			.pipe(changed(paths.coffee_scripts.dest_locales, { extension: '.json' }))
			.pipe(cson().on('error', handleError))
			.pipe(rename({extname: '.json'}))
			.pipe(gulp.dest(paths.coffee_scripts.dest_locales))
	);
});

/**
 * Gulp Task: app_scripts - concat and optionally uglify the app scripts into app.js (includes sourcemapping)
 * @return {stream} gulp stream
 */
gulp.task('app_scripts', ['version','coffee'], function() {

	return gulp.src(paths.app_scripts.src)
			.pipe(sourcemaps.init({loadMaps: true}))
				.pipe(concat(options.isProd ? 'app.min.js' : 'app.js'))
	    		.pipe(gulp.dest(paths.app_scripts.dest))
	    		.pipe( options.isProd ? uglify() : gutil.noop() )
			.pipe(sourcemaps.write('.'))
	    	.pipe(gulp.dest(paths.app_scripts.dest))
			.pipe(size({title:'app_scripts'}));
});

/**
 * Gulp Task: vendor_scripts - concat and optionally uglify the vendor scripts into vendor.js (includes sourcemapping)	
 * @return {stream} gulp stream
 */
gulp.task('vendor_scripts', function() {
	var assets = useref.assets({searchPath: paths.vendor_scripts.search_path});

	return merge(
		//copy all of the vendor scripts to the .tmp folder
		gulp.src(paths.vendor_scripts.src_all)
			.pipe(changed(paths.vendor_scripts.dest_all))
			.pipe(gulp.dest(paths.vendor_scripts.dest_all)),

		//grab the includes from the index.html and combine them
		gulp.src(paths.vendor_scripts.src_html)
			.pipe(assets)
			.pipe(gulpif('*.js', uglify().on('error', handleError)))			//todo: if want to include maps on these... try to use lazy stream
			.pipe(gulpif('*.css', minifyCSS()))			
			.pipe(assets.restore())
			.pipe(useref())
			.pipe(gulp.dest(paths.vendor_scripts.dest_html))
	);
});

/**
 * Gulp Task: Version - write out the version file
 * @param {callback} cb used by gulp to know when the task has completed
 */
gulp.task('version', function(cb){
	execute('git describe --tags', function(version){
		execute('git rev-parse --short HEAD', function(build){
			fs.writeFile(
				path.join(__dirname, paths.app_scripts.src_version), 
				'window.Tangerine.buildVersion = "'+build.replace(/\n/,'')+'"; window.Tangerine.version = "'+version.replace(/\n/,'')+'";',
				function(err){
					gutil.log(err)
					cb();
			});
		});
	});

});

/**
 * Gulp Task: db_scripts - copy all of the couchdb files over
 * @return {stream} gulp stream
 */
gulp.task('db_scripts', function() {

	return gulp.src(paths.db_scripts.src, { base: '.tmp' })
		.pipe(changed(paths.db_scripts.dest))
		.pipe(gulp.dest(paths.db_scripts.dest));
});

/**
 * Gulp Task: styles - compile less and copy other styles to the dest dir 
 * @return {stream} gulp stream
 */
gulp.task('styles', function() {

	return merge(
		//copy any css or ttf files from the css dir
		gulp.src(paths.styles.src_other)
			.pipe(changed(paths.styles.dest))
			.pipe(gulp.dest(paths.styles.dest)),

		//compile the less file and copy it to the dest dir
		gulp.src(paths.styles.src_less)
			.pipe(changed(paths.styles.dest, { extension: '.css' }))
			.pipe(sourcemaps.init())
				.pipe(less().on('error', handleError))
    			.pipe( options.isProd ? minifyCSS({keepSpecialComments:0}) : gutil.noop() ) // only minify css if prod
			.pipe(sourcemaps.write('.'))
			.pipe(gulp.dest(paths.styles.dest))
	);
});

/**
 * Gulp Task: images - compress images and copy them to the build directory
 * @return {stream} return the stream for async operations
 */
gulp.task('images', function() {
	return gulp.src(paths.images.src)
		.pipe(changed(paths.images.dest))
		.pipe( options.isProd ? imagemin({optimizationLevel: 5}) : gutil.noop() ) // only compress images if prod
		.pipe(gulp.dest(paths.images.dest))
		.pipe(size({title:'images'}));
});

/**
 * Gulp Task: html - inject any css and js into the html file
 * @return {stream} gulp stream
 */
gulp.task('html', function() {
	var target = gulp.src(paths.inject.src_html);

	return target.pipe(inject(gulp.src(paths.inject.src_js, {read:false}), {name: 'app', relative:true}))
		.pipe(gulp.dest(paths.inject.dest_html));
});

/**
 * Gulp Task: couch_copy - copy the non-_attachment assets into the build directory 
 * @return {stream} gulp stream
 */
gulp.task('couch_copy', function() {

	return gulp.src(paths.couchapp.src, { base: 'app/' })
		.pipe(changed(paths.couchapp.dest))
		.pipe(gulp.dest(paths.couchapp.dest));
});

/**
 * Gulp Task: couchapp_start - push the current build directory into couch
 * @param  {Function} cb callback to notify gulp that this task has completed
 */
gulp.task('couchapp_push', function(cb) {
	var cwd = path.join(__dirname, 'dist/app/');
	var cmd = new run.Command('couchapp push'+ (options.openBrowser ? ' -b' : '') , {cwd:cwd, verbosity:2});
	cmd.exec('', cb);
	options.openBrowser = false; //only open the browser window on startup
});

/**
 * Gulp Task: watch - monitor the dirs for changed files and recompile things
 * @return {stream} gulp stream
 */
gulp.task('watch', function() {
	//used by lint_coffeescript to enforce a complete lint on startup
	options.isWatching = true;

	// CoffeeScript files
	gulp.watch(paths.coffee_scripts.src_all, function(event) { runSequence('lint_coffee', 'app_scripts', 'couchapp_push'); logChange(event); }); 
	gulp.watch(paths.coffee_scripts.src_locales, function(event) { runSequence('coffee', 'couchapp_push'); logChange(event); }); 

	// Vendor Scripts
	gulp.watch(paths.vendor_scripts.src_all.concat(paths.vendor_scripts.src_html), function(event) { 
		runSequence('vendor_scripts', 'html', 'couchapp_push'); logChange(event); 
	}); 

	// DB Scripts
	gulp.watch(paths.db_scripts.src, function(event) { 
		runSequence('db_scripts', 'couchapp_push'); logChange(event); 
	}); 

	// Styles Scripts
	gulp.watch(paths.styles.src_less.concat(paths.styles.src_other), function(event) { 
		runSequence('styles', 'couchapp_push'); logChange(event); 
	}); 

	//Images
	gulp.watch(paths.images.src, function(event) { runSequence('images', 'couchapp_push'); logChange(event); }); 

	// HTML Files
	gulp.watch(paths.inject.src_html, function(event) { runSequence('html', 'couchapp_push'); logChange(event); }); 

	//couchapp config files
	gulp.watch(paths.couchapp.src, function(event) { runSequence('couch_copy', 'couchapp_push'); logChange(event); }); 

});


/************************ Primary Gulp Tasks ************************/

/**
 * Perform a full build operation and copy the files into the build directory
 */
gulp.task('build', function(callback){
	introMessage("Production");
	options.isProd = true;
	//remove runSequence when upgrading to the upcoming Gulp v4
	runSequence(
		'clean',
		'styles',
		'lint_coffee',
		['app_scripts', 'vendor_scripts', 'images'],
		'db_scripts',
		'html',
		'couch_copy',
		'couchapp_push',
		callback
	);
	options.isProd = false;
});

/**
 * Default build operation for development purposes
 */
gulp.task('default', function(callback){
	introMessage("Development");
	//remove runSequence when upgrading to the upcoming Gulp v4
	runSequence(
		'styles',
		'lint_coffee',
		['app_scripts', 'vendor_scripts', 'images'],
		'db_scripts',
		'html',
		'couch_copy',
		'couchapp_push',
		'watch',
		callback
	);
});





