
_ = require 'underscore'
_.str = require 'underscore.string'
db = require './models'

value2js = (value) ->
    if value is 'true'
        value = true
    else if value is 'false'
        value = false
    else if parseFloat(value)+'' is value
        value = parseFloat(value)
    return value


exports.find = (req, res) ->
    type = req.params.type
    unless type
        return res.json({error: 'no type found'})

    type = _.str.classify type
    unless db[type]?
        return res.json({error: "unknown type: #{type}"})

    options = {limit: 30, populate: false}

    query = {}
    for key, value of req.query
        if _.str.startsWith key, '_'
            value = value2js(req.query[key])
            if value?
                options[key[1..]] = value2js(value)
        else
            query[key] = value2js(value)

    db[type].find query, options, (err, results) ->
        if err
            return res.json({error: err.message})
        return res.json(obj.toJSONObject({populate: options.populate}) for obj in results)
