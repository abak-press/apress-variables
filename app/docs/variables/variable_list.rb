Apress::Documentation.build(:variables, title: 'Переменные') do
  document(:variable_list, title: 'Список переменных') do
    description <<-TEXT
      Хранит экземпляры класса Variable.
      <br>Имеет DSL для удобного создания списка переменных.
      <br>У каждой переменной есть контекст - набор параметров, необходимых для ее расчета.
      <br>В списке могут храниться переменные с разными контекстами.
      <br>ID переменной уникален в пределах одного списка.
      <br>Если в список добавляются 2 переменные с одинаковыми ID и контекстом, сохраняется последняя.
      <br>Пример:
      <pre>
       List.add_variables do
         variable do
           context     :user_id
           id          'user:id'
           desc        'ID пользователя'
           source_proc ->(params, args) { params.fetch(:user_id).to_s }
         end
       end
      </pre>
    TEXT
  end
end
