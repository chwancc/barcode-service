const Koa = require('koa');
const fs = require('fs');
const http = require('http');
const zlib = require('zlib');
const cookies = require('cookie');
const axios = require('axios');
const iconv = require('iconv-lite');
const Router = require('@koa/router');
const cheerio = require('cheerio');

const app = new Koa();
const router = new Router();

function getWithPromise(url, option) {
  let promise = new Promise(function (resolve, rejecte) {
    let req = http.get(url, option)
    req.on("response", function (res) {
      let arr = [];
      let length = 0;
      res.on("data", function (chunk) {
        arr.push(chunk);
        length += chunk.length;
      });
      res.on('end', function (date) {
        let htmlBuffer = Buffer.concat(arr, length);
        zlib.unzip(htmlBuffer, (err, buffer) => {
          if (!err) {
            // console.log(buffer.toString());
          } else {
            // 处理错误
            rejecte(err)
          }
          let html = iconv.decode(buffer, 'gb2312');
          resolve(html);
        });
      })
    });
  })
  return promise;
}

function readFile() {
  let promise = new Promise(function (resolve, rejecte) {
    fs.readFile('./src/header.txt', 'utf8', (err, data) => {
      if (err) {
        rejecte(err);
      }
      resolve(data);
    });
  })
  return promise;
}

// https://raw.githubusercontent.com/chwan-cc/config-center/master/config-header.txt
function getFile() {
  let promise = new Promise(function (resolve, rejecte) {
    let url = 'https://raw.githubusercontent.com/chwan-cc/header/master/config-header.txt';
    let req = https.get(url)
    req.on("response", function (res) {
      let str = '';
      res.on("data", function (chunk) {
        str += chunk;
      });
      res.on('end', function (date) {
        resolve(str);
      })
    });
  })
  return promise;
}

function rawToJson(raw) {
  const matrixArray = raw.split('\n').map((item) => item.split(':').map(item => item.trim()));
  const headerJson = {};
  matrixArray.forEach(array => {
    headerJson[array[0]] = array[1];
  })
  return headerJson;
}

function getAuthSession() {
  let promise = new Promise(function (resolve, rejecte) {
    try {
      axios.get('http://search.anccnet.com/writeSession.aspx?responseResult=check_ok',
        {
          headers: {
            Referrer: "http://www.gds.org.cn/",
            Host: "search.anccnet.com",
            Connection: "Keep-Alive",
          }
        })
        .then(function (response) {
          let cookie = cookies.parse(response.headers['set-cookie'][0]);
          if (!cookie['ASP.NET_SessionId']) throw new Error(" can't get session");
          resolve(cookie['ASP.NET_SessionId']);
        })
    } catch (error) {
      rejecte(error)
    }
  })
  return promise;
}

// TODO 错误处理 解析html返回json 通过docker file部署到腾讯云服务器
router.get('/getGoodsInfoFromBarCode', async (ctx, next) => {
  try {
    const options = {
      headers: null,
    }
    let rawHeaders = await readFile();
    options.headers = rawToJson(rawHeaders);
    const authStr = await getAuthSession();
    options.headers.cookie = cookies.serialize('ASP.NET_SessionId', authStr);
    if(!ctx.query.barCode) throw new Error("code don't exist");
    const url = `http://search.anccnet.com/searchResult2.aspx?keyword=${ctx.query.barCode}`;
    let html = await getWithPromise(url, options);
    // console.log(html);
    if(!html) throw new Error("html wrong");

    const $ = cheerio.load(html);
    if (!$('.p-supplier')[0] || !$('.p-info')[0]) {
      throw new Error("can't find useful things");
    }

    // 依次获得  商标 发布厂家 条码状态 / 商品信息地址 名称 规格型号 描述
    // 使用text 用html会得到转移中文
    const goodsInfo = {
      brand: $($('.p-supplier dd').get(0)).text(),
      producer: $($('.p-supplier dd').get(1)).find('a').text(),
      goodsLink: $($('.p-info dd').get(0)).find('a').attr('href'),
      name: $($('.p-info dd').get(3)).text(),
      standard: $($('.p-info dd').get(4)).text(),
      describe: $($('.p-info dd').get(5)).text(),
    }
    for(const key in goodsInfo) {
      if(!goodsInfo[key]) {
        if(['name', 'producer'].indexOf(key) !== -1) {
          goodsInfo.incomplete = true;
        }
        delete goodsInfo[key];
      }
    }

    ctx.set("Content-Type", "application/json")
    ctx.body = JSON.stringify(goodsInfo);
  } catch (e) {
    ctx.throw(400, e);
  }
  next();
});

app.use(router.routes())
  .use(router.allowedMethods());

app.listen(3000);


