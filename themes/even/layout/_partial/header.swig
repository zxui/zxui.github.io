<div class="logo-wrapper bounce">
  <a href="{{ url_for('.') }}" class="logo">{{ config.title }}</a>
</div>

<nav class="site-navbar">
  {% if theme.menu %}
    <ul id="menu" class="menu">
      {% for name, path in theme.menu %}
        <li class="menu-item">
          <a class="menu-item-link" href="{{ url_for(path) }}">
            {% set itemName = __('menu.' + name.toLowerCase()) %}
            {% if itemName.startsWith('menu') %}
              {{ name }}
            {% else %}
                {% if itemName.startsWith('博客') %}
                    {{ itemName }}<sup class="el-badge__content is-fixed">9</sup>
                {% elseif itemName.startsWith('作品') %}
                    {{ itemName }}<sup class="el-badge__content is-fixed">5</sup>
                {% elseif itemName.startsWith('首页') %}
                    {{ itemName }}<sup class="el-badge__content is-fixed">hot</sup>
                {% elseif itemName.startsWith('关于') %}
                    {{ itemName }}<sup class="el-badge__content is-fixed">new</sup>
                {% else %}
                    {{ itemName }}
                {% endif %}
            {% endif %}
          </a>
        </li>
      {% endfor %}
      {% if theme.theme.search %}
        <li class="menu-search">
          <form>
            <i class="iconfont icon-search" id="open-search"></i>
            <input type="text" class="search-input" id="search-input" />
            <i class="iconfont icon-close" id="close-search"></i>
          </form>
        </li>
      {% endif %}
    </ul>
  {% endif %}
</nav>
