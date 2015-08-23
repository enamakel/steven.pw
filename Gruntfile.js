module.exports = function (grunt) {
	"use strict";

	grunt.initConfig({

		/*! Compile and Minify the SASS files. */
		sass: {
			style: {
				files: {
					// 'css/build/style.css' : 'css/src/master.scss',
					'css/build/home.css'      : 'css/src/home.scss',
					'css/build/blog-post.css' : 'css/src/blog-post.scss'
				},
				options: { style: 'compressed' },
			},
		},


		watch: {
			css: {
				files: ['css/src/**/*.scss'],
				options: { livereload: true },
				tasks: ['css'],
			},
			html: {
				files: [
					'jade/**/*.jade',
				],
				tasks: ['html']
			},
		},

		exec: {
			four_o_four: 'jade ./jade/404.jade --out ./public/',
			about: 'jade ./jade/a.jade --out ./public/',
			blog: 'jade ./jade/b/*.jade --out ./public/b/',
			home: 'jade ./jade/index.jade --out ./public/'
		},
	});

	/*! Load grunt modules */
	grunt.loadNpmTasks('grunt-contrib-sass');
	grunt.loadNpmTasks('grunt-contrib-watch');
	grunt.loadNpmTasks('grunt-exec');


	/*! Custom Grunt task definitions */
	grunt.registerTask('css', 'Compiles the CSS files', function() {
		grunt.task.run(['sass', 'html']);
	});
	grunt.registerTask('html', 'Compiles the HTML files', function() {
		grunt.task.run(['exec']);
	});


	/*! Set default grunt task */
	grunt.registerTask('default', ['css']);
};
