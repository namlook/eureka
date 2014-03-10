
express = require 'express'
engine = require './engine'

class Eureka

    constructor: (@config) ->
        baseApi = "/api/#{config.version}"
        @db = @getDatabase()

        @app = express()
        # app.use("/public", express.static("#{__dirname}/../public"))
        # app.use(express.bodyParser())
        @app.use(express.urlencoded())
        @app.use(express.json())
        @app.use (req, res, next) =>
            req.db = @db
            next()

        @app.get     "#{baseApi}/:type/count",            engine.count
        @app.get     "#{baseApi}/:type/facets/:field",    engine.facets
        @app.get     "#{baseApi}/:type",                  engine.find
        @app.get     "#{baseApi}/_id",                  engine.findIds


    getDatabase: () ->
        unless @config.database?
            return 'Eureka needs a database'
        if @config.database.dbtype?
            return @config.database

        unless @config.database.adapter?
            return 'Eureka needs a database adapter'

        Model = require "../../archimedes/src/#{@config.database.adapter}/model"

        models = {}
        for modelName, modelInfos of @config.schemas
            models[modelName] = Model.extend(modelInfos)

        Database = require "../../archimedes/src/#{@config.database.adapter}/database"
        db = new Database @config.database.config
        db.registerModels models
        return db


    start: (port) ->
        port = port or @config.port
        @app.listen(port)

# app.get     '/api/facets/:facet',       api.facets
# app.get     '/api/facets',              api.facets
# app.get     '/api/describes',           api.describes
# app.get     '/api/documents',           api.find
# app.get     '/api/query',               api.describeQuery
# app.get     '/api/count',               api.count
# app.get     '/api/:type/describes',     api.describes
# app.get     '/api/:type/facets/:facet', api.facets
# app.get     '/api/:type/facets',        api.facets
# app.get     '/api/:type/documents/:id', api.findOne
# app.get     '/api/:type/documents',     api.find
# app.get     '/api/:type/query',         api.describeQuery
# app.get     '/api/:type/count',         api.count
# app.get     '/api/:type',               api.all

module.exports = Eureka
