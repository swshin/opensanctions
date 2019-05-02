from urllib.parse import urljoin
from normality import slugify, collapse_spaces, stringify
from pprint import pprint  # noqa

from opensanctions import constants
from opensanctions.util import EntityEmitter
from opensanctions.util import jointext

import json

SEXES = {
    'M': constants.MALE,
    'F': constants.FEMALE,
}


def element_text(el):
    if el is None:
        return
    text = stringify(el.text_content())
    if text is not None:
        return collapse_spaces(text)


def parse(context, data):
    emitter = EntityEmitter(context)
    
    url = data.get('url')
   
    context.log.info("Interpol Red Notices URL: %s", url)
    
    with context.http.get(url) as result:

        context.log.info("result.text=%s", result.text);

        dict = json.loads(result.text)
        name = jointext(dict['forename'], dict['name'])
        if name is None or name == 'Identity unknown':
            return
        entity = emitter.make('Person')
        entity.make_id(url)
        entity.add('name', name)
        entity.add('sourceUrl', url)
        description = dict['distinguishing_marks']
        entity.add('description', description)
        entity.add('keywords', 'REDNOTICE')
        entity.add('keywords', 'CRIME')

        if ', ' in name:
            last, first = name.split(', ', 1)
            entity.add('alias', jointext(first, last))

        warrants = dict['arrest_warrants']
        summary = ''        
        for warrant in warrants:
            issuingCountryId = jointext('[', warrant['issuing_country_id'], ']', sep='')
            charge = jointext(issuingCountryId, warrant['charge'])
            summary = jointext(summary, charge, sep='\r\n')

        entity.add('summary', summary)
        entity.add('lastName', dict['name'])
        entity.add('firstName', dict['forename'])
        entity.add('nationality', dict['nationalities'])
        entity.add('gender', SEXES[dict['sex_id']])
        entity.add('birthDate', dict['date_of_birth'])
        entity.add('birthPlace', dict['place_of_birth'])

        emitter.emit(entity)


def index(context, data):
    page = data.get('page', 1)
    url = context.params.get('url')
    url = url % (page)
    
    res = context.http.get(url)
    dict = json.loads(res.text)

    embedded = dict['_embedded']
    notices = embedded['notices']

    for notice in notices:
        links = notice['_links']
        self = links['self']
        href = self['href']
        
        context.emit(data={'url': href})

    total = dict['total']
    query = dict['query']
    resultPerPage = query['resultPerPage']

    if page > total / resultPerPage:
        return
        
    context.recurse(data={'page': page + 1})
