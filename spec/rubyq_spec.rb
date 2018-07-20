require 'rubyq'

RSpec.describe Rubyq do
  it 'has a version number' do
    expect(Rubyq::VERSION).not_to be nil
    expect(Rubyq::VERSION).to eq('0.1.0')
  end
end

RSpec.describe Rubyq::QueryBuilder do
  subject { Rubyq::QueryBuilder.new }
  it 'select without table' do
    expect(subject.get_query).to eq('SELECT *')
    expect(subject.select('1').get_query).to eq('SELECT 1')
  end

  it 'select without field' do
    expect(subject.from('my_table').get_query).to eq('SELECT * FROM my_table')
    expect(subject.from('my_table').where('id = 1').get_query).to eq('SELECT * FROM my_table WHERE id = 1')
  end

  it 'select with fields' do
    expect(subject.select('id').from('my_table').get_query).to eq('SELECT id FROM my_table')
    expect(subject.select(%w(id name)).from('my_table').get_query).to eq('SELECT id, name FROM my_table')
  end

  it 'select distinct' do
    expect(subject.select('id').from('my_table').distinct.get_query).to eq('SELECT DISTINCT id FROM my_table')
  end

  it 'select with where condition' do
    expect(subject.from('my_table').where('id = 1').get_query).to eq('SELECT * FROM my_table WHERE id = 1')
    expect(subject.from('my_table').and_where('id = 1').get_query).to eq('SELECT * FROM my_table WHERE id = 1')
    expect(subject.from('my_table').or_where('id = 1').get_query).to eq('SELECT * FROM my_table WHERE id = 1')

    expect(subject.from('my_table').and_where('id = 1').or_where("name = 'myname'").get_query).to eq("SELECT * FROM my_table WHERE id = 1 OR name = 'myname'")
    expect(subject.from('my_table').and_where('id = 1').and_where("name = 'myname'").get_query).to eq("SELECT * FROM my_table WHERE id = 1 AND name = 'myname'")

    expect(subject.from('my_table').where('id = 1').where("name = 'myname'").get_query).to eq("SELECT * FROM my_table WHERE name = 'myname'")
    expect(subject.from('my_table').and_where('id = 1').where("name = 'myname'").get_query).to eq("SELECT * FROM my_table WHERE name = 'myname'")
    expect(subject.from('my_table').or_where('id = 1').where("name = 'myname'").get_query).to eq("SELECT * FROM my_table WHERE name = 'myname'")
  end

  it 'select with group_by' do
    expect(subject.from('my_table').group_by('name').get_query).to eq('SELECT * FROM my_table GROUP BY name')
    expect(subject.from('my_table').group_by('field1').group_by('field2').get_query).to eq('SELECT * FROM my_table GROUP BY field1, field2')
  end

  it 'select with order by' do
    expect(subject.from('my_table').order_by('name').get_query).to eq('SELECT * FROM my_table ORDER BY name')
    expect(subject.from('my_table').order_by('field1', 'DESC').order_by('field2').get_query).to eq('SELECT * FROM my_table ORDER BY field1 DESC, field2')
  end

  it 'complete select statement' do
    expected = "SELECT id FROM my_table WHERE status = 'enabled' GROUP BY id ORDER BY name"
    expect(subject.select('id').from('my_table').order_by('name').where("status = 'enabled'").group_by('id').get_query).to eq(expected)

    expected = "SELECT DISTINCT id FROM my_table WHERE status = 'enabled' GROUP BY id ORDER BY name"
    expect(subject.select('id').distinct.from('my_table').order_by('name').where("status = 'enabled'").group_by('id').get_query).to eq(expected)
  end

  it 'update statement' do
    expect(subject.update('my_table').set('name', 'newname').get_query).to eq("UPDATE my_table SET name = 'newname'")
    expect(subject.update('my_table').set('name', 'newname').where('id = 1').get_query).to eq("UPDATE my_table SET name = 'newname' WHERE id = 1")
    expect(subject.update('my_table').set('name', 'newname').where('field1 = enabled').order_by('name').get_query).to eq("UPDATE my_table SET name = 'newname' WHERE field1 = enabled ORDER BY name")
  end

  it 'update statement with from' do
    expect { subject.update('my_table').from('my_table_too').get_query }.to raise_exception('This method only for SELECT')
  end

  it 'update statement' do
    expect(subject.delete('my_table').get_query).to eq("DELETE my_table")
    expect(subject.delete('my_table').where('id = 1').get_query).to eq("DELETE my_table WHERE id = 1")
    expect(subject.delete('my_table').where('field1 = enabled').order_by('name').get_query).to eq("DELETE my_table WHERE field1 = enabled ORDER BY name")
  end
end
