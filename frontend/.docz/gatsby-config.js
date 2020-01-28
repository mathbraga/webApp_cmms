const { mergeWith } = require('lodash/fp')
const fs = require('fs-extra')

let custom = {}
const hasGatsbyConfig = fs.existsSync('./gatsby-config.custom.js')

if (hasGatsbyConfig) {
  try {
    custom = require('./gatsby-config.custom')
  } catch (err) {
    console.error(
      `Failed to load your gatsby-config.js file : `,
      JSON.stringify(err),
    )
  }
}

const config = {
  pathPrefix: '/',

  siteMetadata: {
    title: 'Sf Sinfra Cmms',
    description: 'CMMS SINFRA - Senado Federal',
  },
  plugins: [
    {
      resolve: 'gatsby-theme-docz',
      options: {
        themeConfig: {},
        themesDir: 'src',
        mdxExtensions: ['.md', '.mdx'],
        docgenConfig: {},
        menu: [],
        mdPlugins: [],
        hastPlugins: [],
        ignore: [],
        typescript: false,
        ts: false,
        propsParser: true,
        'props-parser': true,
        debug: false,
        native: false,
        openBrowser: false,
        o: false,
        open: false,
        'open-browser': false,
        root:
          'D:\\Users\\pedrohs\\Desktop\\Pedro\\Computer Science\\senado_federal\\cmms-web-app\\frontend\\.docz',
        base: '/',
        source: './',
        src: './',
        files: '**/*.{md,markdown,mdx}',
        public: '/public',
        dest: '.docz/dist',
        d: '.docz/dist',
        editBranch: 'master',
        eb: 'master',
        'edit-branch': 'master',
        config: '',
        title: 'Sf Sinfra Cmms',
        description: 'CMMS SINFRA - Senado Federal',
        host: 'localhost',
        port: 3000,
        p: 3000,
        separator: '-',
        paths: {
          root:
            'D:\\Users\\pedrohs\\Desktop\\Pedro\\Computer Science\\senado_federal\\cmms-web-app\\frontend',
          templates:
            'D:\\Users\\pedrohs\\Desktop\\Pedro\\Computer Science\\senado_federal\\cmms-web-app\\frontend\\node_modules\\docz-core\\dist\\templates',
          docz:
            'D:\\Users\\pedrohs\\Desktop\\Pedro\\Computer Science\\senado_federal\\cmms-web-app\\frontend\\.docz',
          cache:
            'D:\\Users\\pedrohs\\Desktop\\Pedro\\Computer Science\\senado_federal\\cmms-web-app\\frontend\\.docz\\.cache',
          app:
            'D:\\Users\\pedrohs\\Desktop\\Pedro\\Computer Science\\senado_federal\\cmms-web-app\\frontend\\.docz\\app',
          appPackageJson:
            'D:\\Users\\pedrohs\\Desktop\\Pedro\\Computer Science\\senado_federal\\cmms-web-app\\frontend\\package.json',
          gatsbyConfig:
            'D:\\Users\\pedrohs\\Desktop\\Pedro\\Computer Science\\senado_federal\\cmms-web-app\\frontend\\gatsby-config.js',
          gatsbyBrowser:
            'D:\\Users\\pedrohs\\Desktop\\Pedro\\Computer Science\\senado_federal\\cmms-web-app\\frontend\\gatsby-browser.js',
          gatsbyNode:
            'D:\\Users\\pedrohs\\Desktop\\Pedro\\Computer Science\\senado_federal\\cmms-web-app\\frontend\\gatsby-node.js',
          gatsbySSR:
            'D:\\Users\\pedrohs\\Desktop\\Pedro\\Computer Science\\senado_federal\\cmms-web-app\\frontend\\gatsby-ssr.js',
          importsJs:
            'D:\\Users\\pedrohs\\Desktop\\Pedro\\Computer Science\\senado_federal\\cmms-web-app\\frontend\\.docz\\app\\imports.js',
          rootJs:
            'D:\\Users\\pedrohs\\Desktop\\Pedro\\Computer Science\\senado_federal\\cmms-web-app\\frontend\\.docz\\app\\root.jsx',
          indexJs:
            'D:\\Users\\pedrohs\\Desktop\\Pedro\\Computer Science\\senado_federal\\cmms-web-app\\frontend\\.docz\\app\\index.jsx',
          indexHtml:
            'D:\\Users\\pedrohs\\Desktop\\Pedro\\Computer Science\\senado_federal\\cmms-web-app\\frontend\\.docz\\app\\index.html',
          db:
            'D:\\Users\\pedrohs\\Desktop\\Pedro\\Computer Science\\senado_federal\\cmms-web-app\\frontend\\.docz\\app\\db.json',
        },
      },
    },
  ],
}

const merge = mergeWith((objValue, srcValue) => {
  if (Array.isArray(objValue)) {
    return objValue.concat(srcValue)
  }
})

module.exports = merge(config, custom)
