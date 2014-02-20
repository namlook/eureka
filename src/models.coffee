

Model = require('../../archimedes/src/rdf/model')
Database = require('../../archimedes/src/rdf/database')
db = new Database {
    store: 'virtuoso'
    #namespace: 'http://onto.bdhs.com'
    #defaultInstancesNamespace: 'http://data.bdhs.com'
    graphURI: 'http://ceropath.org'
}

# Model = require('../archimedes/src/interface/model')
# Database = require('../archimedes/src/nedb/database')
# db = new Database


models = {}


class models.Publication extends Model
    schema:
        source:
            type: 'string'
        remark:
            type: 'string'
        link:
            type: 'url'
        reference:
            type: 'string'


class models.TaxonomicRank extends Model
    schema:
        kingdom:
            type: 'string'
        division:
            type: 'string'
        superfamily:
            type: 'string'
        genus:
            type: 'string'
        subgenus:
            type: 'string'
        suborder:
            type: 'string'
        family:
            type: 'string'
        tribe:
            type: 'string'
        infraorder:
            type: 'string'
        class:
            type: 'string'
        strain:
            type: 'string'
        phylum:
            type: 'string'
        taxonLevel:
            type: 'string'
        groups:
            type: 'string'
        species:
            type: 'string'
        subspecies:
            type: 'string'
        subfamily:
            type: 'string'
        order:
            type: 'string'
        extinct:
            type: 'boolean'

class models.Iucn extends Model
    schema:
        red_list_criteria_version:
            type: 'string'
        trend:
            type: 'string'
        year_assessed:
            type: 'string'
        status:
            type: 'string'
        id:
            type: 'string'


class models.Msw3 extends Model
    schema:
        status:
            type: 'string'
        display_order:
            type: 'string'
        sort_order:
            type: 'string'
        file:
            type: 'string'
        distribution:
            type: 'string'


class models.OrganismClassification extends Model
    schema:
        title:
            type: 'string'
            i18n: true
        type:
            type: 'string'
        remark:
            type: 'string'
        displayOnlyMolIdentif:
            type: 'boolean'
        reference:
            type: 'string'
        internetDisplay:
            type: 'boolean'
        citations:
            type: 'Publication'
            multi: true
        msw3:
            type: 'Msw3'


db.registerModels models

module.exports = db

if require.main is module
    db.OrganismClassification.find {}, {limit: 3, populate: true}, (err, results) ->
        if err
            throw err
        console.log err, (obj.toJSONObject() for obj in results)

