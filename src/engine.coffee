
_ = require 'underscore'
_.str = require 'underscore.string'


#
# Private methods
#

value2js = (value) ->
    if value is 'true'
        value = true
    else if value is 'false'
        value = false
    else if parseFloat(value)+'' is value
        value = parseFloat(value)
    return value

params2pojo = (query) ->
    for key, value of query
        if _.isObject(value) and not _.isArray(value)
            query[key] = params2pojo(value)
        else
            query[key] = value2js(value)
    return query

validateType = (db, type) ->
    error = null
    unless type
        error = 'no type found'
    type = _.str.classify type
    unless db[type]?
        error = "unknown type: #{type}"
    return error

parseQuery = (query) ->
    results = {query: {}, options: {}}
    for key, value of query
        if _.str.startsWith(key, '_') and key not in ['_id', '_type']
            value = value2js(query[key])
            if value?
                results.options[key[1..]] = value
        else
            if value['$in']?
                value = {'$in': value['$in'].split(',')}
            else if value['$exists']?
                val = if value['$exists'] in ['true', '1', 'yes'] then true else false
                value = {'$exists': val}
            else if _.isArray(value) and key isnt '_id'
                value = {'$all': value}
            results.query[key] = value
    return results

# ## count
# returns the number of documents that match the query
# options attributes are prefixed by undescore.
#
# examples:
#   /api/1/organism_classification/count?
#   /api/1/organism_classification/count?internetDisplay=true
exports.count = (req, res) ->
    error = validateType(req.db, req.params.type)
    if error
        return res.json {error: error}
    type = _.str.classify req.params.type

    {query, options} = parseQuery(req.query)

    query = params2pojo(query)
    options = params2pojo(options)

    console.log query, options
    req.db[type].count query, options, (err, results) ->
        if err
            err = err.message if err.message?
            return res.json({error: err})
        return res.json {total: parseInt(results, 10)}


# ## find
# returns all documents that match the query
# options attributes are prefixed by undescore.
#
# examples:
#   /api/1/organism_classification?title@la=bandicota%20indica
#   /api/1/publication&_limit=30
#   /api/1/organism_classification?_populate=true&internetDisplay=true
exports.find = (req, res) ->
    error = validateType(req.db, req.params.type)
    if error
        return res.json {error: error}
    type = _.str.classify req.params.type

    {query, options} = parseQuery(req.query)

    unless options.limit?
        options.limit = 30
    unless options.populate?
        options.populate = false

    options = params2pojo(options)
    query = params2pojo(query)

    options.sortBy = options.sortBy.split(',') if options.sortBy?
    if _.isString(options.populate) and options.populate.indexOf(',') > -1
        options.populate = options.populate.split(',')

    console.log query, options
    req.db[type].find query, options, (err, results) ->
        if err
            err = err.message if err.message?
            return res.json({error: err})
        return res.json {
            results: (o.toJSONObject({populate: options.populate}) for o in results)
        }

# ## findIds
# returns all documents that match the query
# options attributes are prefixed by undescore.
#
# examples:
#   /api/1/_id?_id=http://ceropath.org/instances/individual/c0030
#   /api/1/_id?_id=http://ceropath.org/instances/individual/c0030&_id=http://ceropath.org/instances/individual/c0006
exports.findIds = (req, res) ->

    {query, options} = parseQuery(req.query)

    console.log '°°°°', query, options

    unless options.populate?
        options.populate = false

    options = params2pojo(options)
    query = params2pojo(query)

    if _.isString(options.populate) and options.populate.indexOf(',') > -1
        options.populate = options.populate.split(',')

    console.log '*****', query, options
    req.db[type].find query, options, (err, results) ->
        if err
            err = err.message if err.message?
            return res.json({error: err})
        return res.json {
            results: (o.toJSONObject({populate: options.populate}) for o in results)
        }


# ## facets
# Group the data by a specified field
#
#   /<version>/api/<type>/facet/<field>?[<query>]&[<options>]
#
# examples:
#   /api/1/organism_classification/facets/internetDisplay&_limit=15
#   /api/1/organism_classification/facets/identificationDate?_aggregation=$year-$month&_limit=15
exports.facets = (req, res) ->
    error = validateType(req.db, req.params.type)
    if error
        return res.json {error: error}
    type = _.str.classify req.params.type

    field = req.params.field

    aggregation = null
    if req.query._aggregation?
        aggregation = req.query._aggregation
        delete req.query._aggregation

    {query, options} = parseQuery(req.query)

    options = params2pojo(options)
    query = params2pojo(query)

    unless options.limit?
        options.limit = 30

    console.log field, query, options
    if aggregation
        req.db[type].timeSeries field, aggregation, query, options, (err, results) ->
            if err
                err = err.message if err.message?
                return res.json({error: err})
            return res.json({results: results})
    else
        req.db[type].facets field, query, options, (err, results) ->
            if err
                err = err.message if err.message?
                return res.json({error: err})
            return res.json({results: results})


