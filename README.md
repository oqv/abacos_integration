AbacosIntegration - Setup e Utilização
==============

*Gem criada para consumo do ERP Abacos.*

**Setup:**

- Instale a gem no projeto através do Github.
```ruby
    gem 'abacos_integration', github: 'oqv/abacos_integration.git'
```
- Execute o install:
```shell
    rails g abacos_integration:install
```
- Será gerado na pasta do projeto em config/initializers o arquivo: abacos_integration.rb
```ruby
    AbacosIntegration.configure do |config|
      config.abacos_key = "TOKEN"
      config.abacos_base_path = "URL"
      config.abacos_base_path_only = false
      config.abacos_fetch_price = true
    end
```

- Configure o token e a URL do WebService.

**Utilização:**

Exemplo de requisição de Produtos em uma Classe:
```ruby
    products = AbacosIntegration::Product.new.build_from_parent_products
```

**Métodos disponíveis:**

*Em breve*
