<div id="mobile-navbar" class="mobile-navbar">
  <div class="mobile-header-logo">
    <a href="{{ url_for('.') }}" class="logo">{{ config.title }}</a>
  </div>
  <div class="mobile-navbar-icon">
    <span></span>
    <span></span>
    <span></span>
  </div>
</div>

<nav id="mobile-menu" class="mobile-menu slideout-menu">
  <ul class="mobile-menu-list">
    {% for name, path in theme.menu %}
      <a href="{{ url_for(path) }}">
        <li class="mobile-menu-item">
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
        </li>
      </a>
    {% endfor %}
  </ul>
</nav>
