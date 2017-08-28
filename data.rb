es.index(:blog).create(mappings: {
  post: {
    properties: {
      created: { type: 'date' },
      published: { type: 'date' },
      title: { type: 'text' },
      image: { type: 'text' },
      body: { type: 'text' }
    }
  }
})

5.times do |i|
  es.index(:blog).type(:post).put(i, {
    title: Cicero.sentence,
    body: Cicero.paragraphs(3),
    created: Time.now.to_i,
    published: Time.now.to_i,
    image: "http://i.imgur.com/EuBima4.png"
  })
end
