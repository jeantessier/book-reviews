require('dotenv').config()

require('./open-telemetry')

const express = require('express')
const path = require('path')
const favicon = require('serve-favicon')
const logger = require('morgan')
const cookieParser = require('cookie-parser')
const bodyParser = require('body-parser')
const passport = require('passport')

require('./app_api/models/db')
require('./app_api/config/passport.js')

const routes = require('./routes/index')
const users = require('./routes/users')
const routesApi = require('./app_api/routes/index')

const app = express()

// Do not leak password-related parts of users
const REDACTED_FIELDS = [ 'salt', 'hash' ]
app.set('json replacer', (k, v) => REDACTED_FIELDS.includes(k) ? '[REDACTED]' : v)

// view engine setup
app.set('views', path.join(__dirname, 'views'))
app.set('view engine', 'pug')

// uncomment after placing your favicon in /public
app.use(favicon(path.join(__dirname, 'public', 'favicon.ico')))
app.use(logger('dev'))
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: false }))
app.use(cookieParser())
app.use(express.static(path.join(__dirname, 'public')))

app.use('/', routes)

app.use(passport.initialize())

app.use('/users', users)
app.use('/api', routesApi)

// catch 404 and forward to error handler
app.use((req, res, next) => {
  const err = new Error('Not Found')
  err.status = 404
  next(err)
})

// error handlers

// authentication error handler
// unauthorized user
app.use((err, req, res, _next) => {
    if (err.name === 'UnauthorizedError') {
        res.status(401)
        res.json({"message": err.name + ": " + err.message})
    }
})

// development error handler
// will print stacktrace
if (app.get('env') === 'development') {
  app.use((err, req, res, _next) => {
    res.status(err.status || 500)
    res.render('error', {
      message: err.message,
      error: err,
    })
  })
}

// production error handler
// no stacktraces leaked to user
app.use((err, req, res, _next) => {
  res.status(err.status || 500)
  res.render('error', {
    message: err.message,
    error: {},
  })
})

module.exports = app
