# react 快捷构建

createReact () { # 创建 react 项目
  echo "正在查看 npm 是否全局安装 create-react-app ..."
  npm list --global create-react-app 2>/dev/null 1>/dev/null # 查看全局是否安装 npmReact=$(npm list --global create-react-app)
  if [ $? -ne 0 ]; then #
    echo "需要的包 create-react-app 不存在，需要全局安装(Y/n)"
    read isInstall
    if [ "$isInstall" == 'Y' -o "$isInstall" == 'y' -o -z "$isInstall" ]; then #
      sudo npm i -g create-react-app # npm下安装react环境
    else
      echo "停止"
      exit
    fi
  fi
  echo "\033[36m 请输入你的项目名(必须为英文)：\033[0m"
  read projectName
  create-react-app $projectName # 创建一个项目名为 $projectName 的react项目
  cd $projectName # 进入此项目
}

installNeedLibrary () { # 安装一些基本的第三方库 和 自定义配置模式
  echo "\033[36m 是否安装一些基本的第三方库(Y/n):\033[0m"
  read isInstall
  if [ "$isInstall" == 'Y' -o "$isInstall" == 'y' -o -z "$isInstall" ]; then #
    npm i react-router-dom # react 路由器的DOM绑定（必安装）
    npm i node-sass sass-loader axios es6-promise # 使用sass和axios请求方式
  fi
}

configRequiredDirectories () { # 配置所需目录
  echo "\033[36m 是否自定义配置模式(Y/n):\033[0m"
  read isEject
  if [ "$isEject" == 'Y' -o "$isEject" == 'y' -o -z "$isEject" ]; then #
    echo y | npm run eject # 此时默认的项目结构会发生较大变化，注意观察前后变化
  fi
  installNeedLibrary # 安装一些基本的第三方库
  echo "\033[36m 是否使用基本目录结构(Y/n):\033[0m"
  read isUsed
  if [ "$isUsed" == 'Y' -o "$isUsed" == 'y' -o -z "$isUsed" ]; then #
    cd src && mkdir api components config view router style tools json # 在src下，创建我们需要的文件夹
    rm -r App.css index.css logo.svg # 删除App.css App.test.js index.css logo.svg等无用文件
    cd api && touch index.js && cd ../ # api => index.js
    cd config && touch index.js && cd ../ # config => index.js
    cd router && touch index.js && cd ../ # router => index.js
    cd style && touch index.scss && cd ../ # style => index.scss
    cd tools && touch index.js && cd ../ # tools => indext.js
    cd view && touch home.jsx && cd ../ # view => home.jsx
    touch setupProxy.js
    cat <<EOF >App.js
import React, { Component } from 'react'
import RouterView from './router/index.js'

class App extends Component {
  render() {
    return (
      <RouterView></RouterView>
    )
  }
}

export default App
EOF

    cat <<EOF >index.js
import React from 'react'
import ReactDOM from 'react-dom'
import './style/index.scss'
import App from './App.js'
import * as serviceWorker from './serviceWorker'

ReactDOM.render(<App />, document.getElementById('root'))

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister()
EOF

    cat <<EOF >setupProxy.js
const proxy = require('http-proxy-middleware');

module.exports = function(app) {
  app.use(proxy('/api/v1', {
    target: 'https://cnodejs.org',
    changeOrigin: true
  }));
};
EOF

    cat <<EOF >router/index.js
import React, { Component } from 'react'
import { BrowserRouter as Router, Switch, Route } from 'react-router-dom'

import Home from '../view/home.jsx'

export default class App extends Component {
  render () {
    return (
      <Router basename="/">
        <Switch>
          <Route exact path='/' component={Home} />
        </Switch>
      </Router>
    )
  }
}
EOF

    cat <<EOF >view/home.jsx
import React, { Component } from 'react'
import { Link } from 'react-router-dom' // 路由相关 props.match 等
import Axios from '@/api/index.js'

export default class Home extends Component {
  constructor (props) {
    super(props) // this.props 用来接收父组件的传值 子组件给父组件传值：父组件把操作 state 的方法，通过属性的形式传递给子组件，子组件调用该操作方法
    this.state = {
      list: []
    } // 局部状态
    this.getTopics = this.getTopics.bind(this)
  }

  // React 生命周期--------------------------------------------------------------
  componentDidMount () { // 挂载周期
    this.getTopics()
  }

  componentWillUnmount () { // 卸载周期
  }
  // React 生命周期--------------------------------------------------------------

  // 自定义方法-------------------------------------------------------------------
  getTopics () {
    return new Promise((resolve, reject) => {
      console.log(Axios.original)
      Axios({ method: 'get', url: 'topics', params: {} }).then((response) => {
        console.log(response)
        this.setState({list: response.data}) // 构造函数 setState 更新组件局部状态
        // this.setState((prevState, props) => { // 接收先前的状态作为第一个参数，将此次更新被应用时的props做为第二个参数
        //   return {
        //     ...
        //   }
        // }) // 函数形式
        resolve()
      }).catch((error) => {
        console.log(error)
        reject()
      })
    })
  }
  // 自定义方法-------------------------------------------------------------------

  render () { // render 函数，渲染 dom 结构
    console.log(this)
    let { list } = this.state
    let dom = null

    if (list.length !== 0) {
      let listDom = list.map((item, index, array) => {
        let to = '/details/' + item.id
        return (
          <li key={index}><Link to={to}> {index + 1} - {item.title} </Link></li>
        )
      })
      dom = (<div className='tipics-list'> <ul>{listDom}</ul> </div>)
    }
    return (
      <div className="home">
      首页 {dom}
      </div>
    )
  }
}
EOF

    cat <<EOF >config/index.js
export default {
  projectName: '项目名称', // 项目名称
  title: '项目title',
  /**
   * @description api请求基础路径
   */
  baseUrl: {
    dev: '/api/v1', // 开发环境前缀
    pro: '/api/v1' // 生产环境前缀
  },
  /**
   * @description 是否自行存储token
   */
  isSaveCookie: true,
  /**
   * @description token在Cookie中存储的天数，默认1天
   */
  cookieExpires: 1,
  /**
   * @description 是否使用国际化，默认为false
   * 如果不使用，则需要在路由中给需要在菜单中展示的路由设置 meta: {title: 'xxx'} 用来在菜单中显示文字
   */
  useI18n: false,
  /**
   * @description 默认打开的首页的路由name值，默认为home
   */
  homeName: 'home',
  // ...
  // 其他
}
EOF

    cat <<EOF >style/index.scss
body {
  margin: 0; padding: 0; font-family: sans-serif; font-size: 12px;
}
EOF


    cat <<EOF >api/index.js
// 全局请求插件 Axios
import Config from '@/config'
import Axios from 'axios' // 全局请求插件 Axios

var Promise = require('es6-promise').Promise
var axios = Axios.create() // 实例化

const baseUrl = process.env.NODE_ENV === 'development' ? Config.baseUrl.dev : Config.baseUrl.pro
axios.defaults.baseURL = baseUrl // 接口请求前缀
axios.defaults.withCredentials = true // 是否跨域
axios.defaults.responseType = 'json' // json

// 设置默认请求头
// axios.defaults.headers = {
//   "Content-Type": "application/json"
// }

// `transformResponse` 在请求完成后响应传递给 then/catch 前，允许修改响应数据，函数必须return，function (data) { return data }
// axios.defaults.transformResponse = [(data) => {
//   return data
// }]

// 添加响应拦截器
axios.interceptors.response.use(function (response) { // 请求成功的回调
  return Promise.resolve(response.data)
}, function (error) { // 请求失败的回调
  return Promise.reject(error)
})

axios.original = Axios // 接口请求前缀不一致时的预留

export default axios
EOF

    cd ../
    cd public && mkdir image js && cd ../
  fi
}

# 开始
npm -v 2>/dev/null 1>/dev/null # 2>/dev/null 1>/dev/null 把输出内容丢到黑洞里
if [ $? -ne 0 ]; then #
  echo "程序已停止: npm 尚未安装，请安装后再试"
  exit
else
  cd ~
  mkdir ReactSubject
  cd ReactSubject
  createReact # 创建 react 项目
  echo "项目已经运行完毕，请您查看项目文件和运行结果，查看完毕后，再进行下面操作："
  echo "------------------------------------------------------------------"
  ls
  echo "------------------------------------------------------------------"
  configRequiredDirectories # 配置所需目录
  echo "------------------------------------------------------------------"
  ls
  echo "------------------------------------------------------------------"
  # npm start # 运行项目（项目运行后，查看项目文件和运行结果，查看完毕后，再进行下面操作）
fi
