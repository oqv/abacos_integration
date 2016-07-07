module AbacosIntegration
  class Product < Base
    attr_reader :product_payload, :variants_payload

    def initialize(configuration = {}, payload = {})
      super configuration
      @product_payload = payload[:product] || {}
      @variants_payload = product_payload[:variants] || {}
    end

    # Confirm product (if product.abacos info exists) and its variants. A
    # product payload might not be completely present because Abacos might
    # return the variant but not its master product via Abacos.products_available
    def confirm!
      confirm_integration product_payload
      variants_payload.each { |key, v| confirm_integration v }
    end

    # Abacos return product children (variants) as regular product records
    # so here we need to make sure only parents products are returned with
    # their variants nested in the object
    def fetch
      # handled_collection = build_from_parent_products
      # parent_ids = handled_collection.map { |p| p[:id] }

      # handled_collection + build_from_missing_parents(parent_ids)
      build_from_parent_products + build_from_variants
    end

    def build_from_parent_products
      parent_products.map do |p|
        {
          codigo_produto: p[:codigo_produto],
          acao: p[:acao],
          name: p[:nome_produto],
          sku: p[:codigo_produto],
          description: build_description(p),
          modeling: build_modeling(p),
          class: strip(p[:descricao_classe]),
          brand: strip(p[:descricao_marca]),
          family: strip(p[:descricao_familia]),
          taxons: build_taxons(p),
          taxons_ids: build_taxons_ids(p),
          variants: build_variants(p[:codigo_produto]),
          weight: p[:peso],
          height: p[:altura],
          width: p[:largura],
          length: p[:comprimento],
          option_types: build_options_types(p),
          abacos: clean_up_keys(p)
        }.merge fetch_price(p[:codigo_produto])
      end
    end

    def build_from_variants
      variants_parent_ids = variants.map { |v| v[:codigo_produto_pai] }.uniq

      variants_parent_ids.inject([]) do |objects, parent|

        objects.push(
          id: parent,
          variants: build_variants(parent)
        )

        objects
      end
    end

    def build_from_missing_parents(parent_ids)
      variants_parent_ids = variants.map { |v| v[:codigo_produto_pai] }.uniq

      variants_parent_ids.inject([]) do |objects, parent|
        unless parent_ids.include? parent
          objects.push(
            id: parent,
            variants: build_variants(parent)
          )
        end

        objects
      end
    end

    def build_description(product)
      if product[:descricao].blank?
        if product[:caracteristicas_complementares][:rows][:dados_caracteristicas_complementares].is_a?(Array)
          product[:caracteristicas_complementares][:rows][:dados_caracteristicas_complementares][0][:texto]
        else
          product[:caracteristicas_complementares][:rows][:dados_caracteristicas_complementares][:texto]
        end
      else
        product[:descricao]
      end
    end

    def build_modeling(product)
      if product[:caracteristicas_complementares][:rows][:dados_caracteristicas_complementares].is_a?(Array)
        product[:caracteristicas_complementares][:rows][:dados_caracteristicas_complementares][1][:texto]
      else
        ""
      end
    end

    def parent_products
      @parent_products ||= collection.reject { |p| p[:codigo_produto_pai] }
    end

    def variants
      @variants ||= collection.select { |p| p[:codigo_produto_pai] }
    end

    def products
      @collection = fetch
    end

    def categories
      @categories = Abacos.categories_available
    end

    def families
      @families = Abacos.families_available
    end

    def groups
      @groups = Abacos.groups_available
    end

    def sub_groups
      @groups = Abacos.sub_groups_available
    end

    def brands
      @brands = Abacos.branding_available
    end

    def klasses
      @klasses = Abacos.klasses_available
    end

    def describers
      @describers = Abacos.describers_available
    end

    def fetch_price(product_id)
      if ["1", "true", 1].include? AbacosIntegration.configuration.abacos_fetch_price.to_s
        if price = prices.find { |p| p[:codigo_produto] == product_id }
          if price[:preco_promocional].to_i > 0
            { price: price[:preco_promocional], cost_price: price[:preco_tabela] }
          else
            { price: price[:preco_tabela], cost_price: 0 }
          end
        else
          { price: 0 , cost_price: 0}
        end
      else
        { price: 0, cost_price: 0}
      end
    end

    def build_options_types(product)
      option_types = []
      if rows = product[:descritor_pre_definido][:rows]
        if rows[:dados_descritor_pre_definido].is_a?(Array)
          rows[:dados_descritor_pre_definido]
        else
          [rows[:dados_descritor_pre_definido]]
        end
      else
        []
      end
    end

    def get_category_from_hash(product)
      categories = []
      ids = []
      if rows = product[:categorias_do_site][:rows]
        if rows[:dados_categorias_do_site].is_a?(Array)
          categories = rows[:dados_categorias_do_site]
        else
          categories = [rows[:dados_categorias_do_site]]
        end
      end
      categories.each do |category|
        category_id = category[:codigo_categoria].to_i rescue 0
        ids << category_id if category_id > 0
      end
      ids
    end

    def build_variants(product_id)
      variants = variants_by_product_id product_id

      variants.inject({}) do |items, v|
        sku = v[:codigo_produto]

        items[sku] = {
          sku: sku,
          description: v[:descricao],
          options: build_options_types(v),
          barcode: v[:codigo_barras],
          abacos: clean_up_keys(v)
        }.merge fetch_price(v[:codigo_produto])

        items
      end
    end

    def build_taxons(product)
      taxons = [
        strip(product[:descricao_grupo]), strip(product[:descricao_subgrupo])
      ].compact

      [taxons]
    end

    def build_taxons_ids(product)
      taxons_ids = [
        { :brand => product[:codigo_marca] },
        { :klass => product[:codigo_classe] },
        { :family => product[:codigo_familia] },
        { :group => product[:codigo_grupo] },
        { :sub_group => product[:codigo_sub_grupo] },
        { :category => get_category_from_hash(product)}
      ]
    end

    def variants_by_product_id(product_id)
      variants.select { |v| v[:codigo_produto_pai] == product_id }
    end

    def prices
      @prices ||= Abacos.price_online abacos_ids
    end

    def collection
      @collection ||= Abacos.products_available
    end

    def abacos_ids
      @abacos_ids ||= collection.map { |p| p[:codigo_produto] }
    end

    def confirm_integration(payload)
      if payload[:abacos]
        protocol = payload[:abacos][:protocolo_produto]
        Abacos.confirm_product_received protocol
      end
    end

    def confirm_product_received(protocol)
      @@webservice = "AbacosWSProdutos"
      Abacos.confirm_service "produto", protocol
    end

    def confirm_productvariant_received(protocol)
      @@webservice = "AbacosWSProdutos"
      Abacos.confirm_service "produto", protocol
    end

    # Follows same logic as confirm_product_received
    def confirm_stock_received(protocol)
      @@webservice = "AbacosWSProdutos"
      Abacos.confirm_service "estoque", protocol
    end

    # Confirmacoes de recebimento
    def confirm_brand_received(protocol)
      @@webservice = "AbacosWSProdutos"
      Abacos.confirm_service "marca", protocol
    end

    def confirm_category_received(protocol)
      @@webservice = "AbacosWSProdutos"
      Abacos.confirm_service "categoria_produto", protocol
    end

    def confirm_describer_received(protocol)
      @@webservice = "AbacosWSProdutos"
      Abacos.confirm_service "descritor_pre_definido", protocol
    end

    def confirm_klass_received(protocol)
      @@webservice = "AbacosWSProdutos"
      Abacos.confirm_service "classe", protocol
    end

    def confirm_group_received(protocol)
      @@webservice = "AbacosWSProdutos"
      Abacos.confirm_service "grupo_produto", protocol
    end

    def confirm_subgroup_received(protocol)
      @@webservice = "AbacosWSProdutos"
      Abacos.confirm_service "sub_grupo_produto", protocol
    end

    def confirm_family_received(protocol)
      @@webservice = "AbacosWSProdutos"
      Abacos.confirm_service "familia", protocol
    end

    def confirm_price_received(protocol)
      @@webservice = "AbacosWSProdutos"
      Abacos.confirm_service "preco", protocol
    end


    private
      def clean_up_keys(hash)
        hash.keys.each do |k|
          if k =~ /campo_cfg/
            hash.delete k
          end
        end

        hash
      end

      def strip(string)
        string.to_s.strip! || string
      end

      def useless_keys
        [
          :dados_livros, :descritor_simples, :descritor_pre_definido,
          :atributos_estendidos, :produtos_personalizacao, :categorias_do_site,
          :componentes_kit, :produtos_associados
        ]
      end
  end
end
